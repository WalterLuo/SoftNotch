//
//  ShelfItemView.swift
//  boringNotch
//
//  Maintained by Walterluo for SoftNotch. Original attribution: docs/UPSTREAM_ATTRIBUTIONS.md.
//

import SwiftUI
import AppKit

struct ShelfView: View {
    @EnvironmentObject var vm: BoringViewModel
    @StateObject var tvm = ShelfStateViewModel.shared
    @StateObject var selection = ShelfSelectionModel.shared
    @StateObject private var quickLookService = QuickLookService()
    @State private var itemFrames: [UUID: CGRect] = [:]
    @State private var selectionRect: CGRect?
    private let spacing: CGFloat = 8

    var body: some View {
        HStack(spacing: 12) {
            FileShareView()
                .aspectRatio(1, contentMode: .fit)
                .environmentObject(vm)
            panel
                .onDrop(of: [.fileURL, .url, .utf8PlainText, .plainText, .data], isTargeted: $vm.dragDetectorTargeting) { providers in
                    handleDrop(providers: providers)
                }
        }
        // Bind Quick Look to shelf selection
        .onChange(of: selection.selectedIDs) {
            updateQuickLookSelection()
        }
        .onChange(of: tvm.items) { _, items in
            selection.ensureValidAnchor(in: items)
        }
        .quickLookPresenter(using: quickLookService)
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard !selection.isDragging else { return false }
        vm.dropEvent = true
        ShelfStateViewModel.shared.load(providers)
        return true
    }
    
    private func updateQuickLookSelection() {
        guard quickLookService.isQuickLookOpen && !selection.selectedIDs.isEmpty else { return }
        
        let selectedItems = selection.selectedItems(in: tvm.items)
        let urls: [URL] = selectedItems.compactMap { item in
            if let fileURL = item.fileURL {
                return fileURL
            }
            if case .link(let url) = item.kind {
                return url
            }
            return nil
        }
        
        if !urls.isEmpty {
            quickLookService.updateSelection(urls: urls)
        }
    }

    var panel: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                vm.dragDetectorTargeting
                    ? Color.accentColor.opacity(0.9)
                    : Color.white.opacity(0.1),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [10])
            )
            .overlay {
                content
                    .padding()
            }
            .transaction { transaction in
                transaction.animation = vm.animation
            }
            .contentShape(Rectangle())
            .coordinateSpace(name: "shelfSelection")
            .onPreferenceChange(ShelfItemFrames.self) { itemFrames = $0 }
            .overlay(alignment: .topLeading) {
                if let rect = selectionRect {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.15))
                        .overlay(Rectangle().stroke(Color.accentColor, lineWidth: 1))
                        .frame(width: rect.width, height: rect.height)
                        .offset(x: rect.minX, y: rect.minY)
                        .allowsHitTesting(false)
                }
            }
            .background(GeometryReader { geometry in
                ShelfSelectionInput(
                frames: itemFrames,
                isEnabled: vm.notchState == .open,
                onRectangle: { selectionRect = $0 },
                onDelete: {
                    let selected = selection.selectedItems(in: tvm.items)
                    quickLookService.hide()
                    selected.forEach { tvm.remove($0) }
                    selection.clear()
                }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
            })
    }

    var content: some View {
        Group {
            if tvm.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tray.and.arrow.down")
                        .symbolVariant(.fill)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white, .gray)
                        .imageScale(.large)
                    
                    Text("Drop files here")
                        .foregroundStyle(.gray)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.medium)
                }
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: spacing) {
                        ForEach(tvm.items) { item in
                            ShelfItemView(item: item)
                                .environmentObject(quickLookService)
                                .background(GeometryReader { geometry in
                                    Color.clear.preference(key: ShelfItemFrames.self,
                                        value: [item.id: geometry.frame(in: .named("shelfSelection"))])
                                })
                        }
                    }
                }
                .padding(-spacing)
                .scrollIndicators(.never)
                .onDrop(of: [.fileURL, .url, .utf8PlainText, .plainText, .data], isTargeted: $vm.dragDetectorTargeting) { providers in
                    handleDrop(providers: providers)
                }
            }
        }
        .onAppear {
            ShelfStateViewModel.shared.cleanupInvalidItems()
        }
    }
}

private struct ShelfItemFrames: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

// Observe only this panel's events, leaving file drags on thumbnails intact.
private struct ShelfSelectionInput: NSViewRepresentable {
    let frames: [UUID: CGRect]
    let isEnabled: Bool
    let onRectangle: (CGRect?) -> Void
    let onDelete: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeNSView(context: Context) -> NSView {
        let view = FlippedView()
        context.coordinator.install(view)
        return view
    }
    func updateNSView(_ view: NSView, context: Context) {
        context.coordinator.isEnabled = isEnabled
        context.coordinator.frames = frames
        context.coordinator.onRectangle = onRectangle
        context.coordinator.onDelete = onDelete
    }
    static func dismantleNSView(_ view: NSView, coordinator: Coordinator) { coordinator.remove() }

    final class FlippedView: NSView {
        override var isFlipped: Bool { true }
        override var acceptsFirstResponder: Bool { true }
        // This view only measures the panel and owns keyboard focus. It must not
        // become a mouse target in SwiftUI's shared hosting view (including headers).
        override func hitTest(_ point: NSPoint) -> NSView? { nil }
    }

    @MainActor final class Coordinator {
        var isEnabled = false
        var frames: [UUID: CGRect] = [:]
        var onRectangle: ((CGRect?) -> Void)?
        var onDelete: (() -> Void)?
        private var monitor: Any?
        private var origin: CGPoint?
        private var initialSelection: Set<UUID> = []

        func install(_ view: NSView) {
            monitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseDragged, .leftMouseUp, .keyDown]) { [weak self, weak view] event in
                guard let self, self.isEnabled, let view, let window = view.window,
                      !view.isHiddenOrHasHiddenAncestor, !view.visibleRect.isEmpty,
                      event.window === window else { return event }
                let selection = ShelfSelectionModel.shared
                if event.type == .keyDown {
                    guard window.isKeyWindow, !(window.firstResponder is NSTextView),
                          !selection.isDragging else { return event }
                    if event.keyCode == 51 && event.modifierFlags.intersection([.command, .shift, .option, .control]) == .command,
                       selection.hasSelection {
                        self.onDelete?()
                        return nil
                    }
                    if event.keyCode == 53 {
                        self.origin = nil
                        self.onRectangle?(nil)
                        selection.clear()
                        return nil
                    }
                    return event
                }
                let point = view.convert(event.locationInWindow, from: nil)
                switch event.type {
                case .leftMouseDown:
                    guard view.bounds.intersection(view.visibleRect).contains(point) else {
                        self.origin = nil
                        return event
                    }
                    window.makeKey()
                    window.makeFirstResponder(view)
                    guard !self.frames.values.contains(where: { $0.contains(point) }) else { return event }
                    self.origin = point
                    self.initialSelection = event.modifierFlags.contains(.command) || event.modifierFlags.contains(.shift) ? selection.selectedIDs : []
                    selection.select(self.initialSelection)
                    return nil
                case .leftMouseDragged:
                    guard let origin = self.origin else { return event }
                    let clippedPoint = CGPoint(x: min(max(point.x, view.bounds.minX), view.bounds.maxX),
                                               y: min(max(point.y, view.bounds.minY), view.bounds.maxY))
                    let rect = CGRect(x: min(origin.x, clippedPoint.x), y: min(origin.y, clippedPoint.y),
                                      width: abs(origin.x - clippedPoint.x), height: abs(origin.y - clippedPoint.y))
                    let hits = Set(self.frames.compactMap { id, frame in frame.intersects(rect) ? id : nil })
                    selection.select(self.initialSelection.union(hits))
                    self.onRectangle?(rect)
                    return nil
                case .leftMouseUp:
                    guard self.origin != nil else { return event }
                    self.origin = nil
                    self.onRectangle?(nil)
                    return nil
                default: return event
                }
            }
        }
        func remove() {
            if let monitor { NSEvent.removeMonitor(monitor) }
            monitor = nil
        }
    }
}
