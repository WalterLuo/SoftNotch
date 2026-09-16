//
//  BoringCalendar.swift
//  boringNotch
//
//  Maintained by Walterluo for SoftNotch. Original attribution: docs/UPSTREAM_ATTRIBUTIONS.md.
//

import Defaults
import SwiftUI

struct Config: Equatable {
    //    var count: Int = 10  // 3 days past + today + 7 days future
    var past: Int = 7
    var future: Int = 14
    var steps: Int = 1  // Each step is one day
    var spacing: CGFloat = 0
    var showsText: Bool = true
    var offset: Int = 2  // Number of dates to the left of the selected date
}

struct WheelPicker: View {
    @EnvironmentObject var vm: BoringViewModel
    @Binding var selectedDate: Date
    @State private var scrollPosition: Int?
    @State private var haptics: Bool = false
    @State private var byClick: Bool = false
    let config: Config

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: config.spacing) {
                let spacerNum = config.offset
                let dateCount = totalDateItems()
                let totalItems = dateCount + 2 * spacerNum
                ForEach(0..<totalItems, id: \.self) { index in
                    if index < spacerNum || index >= spacerNum + dateCount {
                        // Leading/trailing spacers sized to match a date cell
                        Spacer()
                            .frame(width: 24, height: 24)
                            .id(index)
                    } else {
                        let date = dateForItemIndex(index: index, spacerNum: spacerNum)
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        dateButton(date: date, isSelected: isSelected, id: index) {
                            selectedDate = date
                            byClick = true
                            withAnimation {
                                scrollPosition = index
                            }
                            if Defaults[.enableHaptics] {
                                haptics.toggle()
                            }
                        }
                    }
                }
            }
            .frame(height: 50)
            .scrollTargetLayout()
        }
        .scrollIndicators(.never)
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .scrollTargetBehavior(.viewAligned)  // Ensures scroll view snaps the centered view
        .safeAreaPadding(.horizontal)
        .sensoryFeedback(.alignment, trigger: haptics)
        .onChange(of: scrollPosition) { oldValue, newValue in
            if !byClick {
                handleScrollChange(newValue: newValue, config: config)
            } else {
                byClick = false
            }
        }
        .onAppear {
            scrollToToday(config: config)
        }
        // When parent updates the bound selectedDate (e.g., view reopen), center the wheel on it
        .onChange(of: selectedDate) { _, newValue in
            let targetIndex = indexForDate(newValue)
            if scrollPosition != targetIndex {
                byClick = true
                withAnimation {
                    scrollPosition = targetIndex
                }
            }
        }
    }

    private func dateButton(
        date: Date, isSelected: Bool, id: Int, onClick: @escaping () -> Void
    ) -> some View {
        let isToday = Calendar.current.isDateInToday(date)
        return Button(action: onClick) {
            VStack(spacing: 8) {
                dayText(date: dateToString(for: date), isToday: isToday, isSelected: isSelected)
                dateCircle(date: date, isToday: isToday, isSelected: isSelected)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
            .background(isSelected ? Color.effectiveAccentBackground : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .id(id)
    }

    private func dayText(date: String, isToday: Bool, isSelected: Bool) -> some View {
        Text(date)
            .font(.caption)
            .foregroundColor(isSelected ? .white : Color(white: 0.65))
    }

    private func dateCircle(date: Date, isToday: Bool, isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isToday ? Color.effectiveAccent : .clear)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0)
                )
            Text("\(date.date)")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : Color(white: isToday ? 0.9 : 0.65))
        }
    }

    func handleScrollChange(newValue: Int?, config: Config) {
        guard let newIndex = newValue else { return }
        let spacerNum = config.offset
        let dateCount = totalDateItems()
        guard (spacerNum..<(spacerNum + dateCount)).contains(newIndex) else { return }
        let date = dateForItemIndex(index: newIndex, spacerNum: spacerNum)
        if !Calendar.current.isDate(date, inSameDayAs: selectedDate) {
            selectedDate = date
            if Defaults[.enableHaptics] {
                haptics.toggle()
            }
        }
    }

    private func scrollToToday(config: Config) {
        let today = Date()
        byClick = true
        scrollPosition = indexForDate(today)
        selectedDate = today
    }

    // MARK: - Index/Date mapping with steps and spacers
    private func indexForDate(_ date: Date) -> Int {
        let spacerNum = config.offset
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let startDate = cal.startOfDay(for: cal.date(byAdding: .day, value: -config.past, to: today) ?? today)
        let target = cal.startOfDay(for: date)
        let days = cal.dateComponents([.day], from: startDate, to: target).day ?? 0
        let stepIndex = max(0, min(days / max(config.steps, 1), totalDateItems() - 1))
        return spacerNum + stepIndex
    }

    private func dateForItemIndex(index: Int, spacerNum: Int) -> Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let startDate = cal.date(byAdding: .day, value: -config.past, to: today) ?? today
        let stepIndex = index - spacerNum
        return cal.date(byAdding: .day, value: stepIndex * max(config.steps, 1), to: startDate) ?? today
    }

    private func totalDateItems() -> Int {
        let range = config.past + config.future
        let step = max(config.steps, 1)
        return Int(ceil(Double(range) / Double(step))) + 1
    }

    private func dateToString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

struct CalendarView: View {
    @EnvironmentObject var vm: BoringViewModel
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading) {
                    Text(selectedDate.formatted(.dateTime.month(.abbreviated)))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text(selectedDate.formatted(.dateTime.year()))
                        .font(.title3)
                        .fontWeight(.light)
                        .foregroundColor(Color(white: 0.65))
                }

                ZStack(alignment: .top) {
                    WheelPicker(selectedDate: $selectedDate, config: Config())
                    HStack(alignment: .top) {
                        LinearGradient(
                            colors: [Color.black, .clear], startPoint: .leading, endPoint: .trailing
                        )
                        .frame(width: 20)
                        Spacer()
                        LinearGradient(
                            colors: [.clear, Color.black], startPoint: .leading, endPoint: .trailing
                        )
                        .frame(width: 20)
                    }
                }
            }

            DailyTodoList(selectedDate: selectedDate)
        }
        .frame(height: 120)
        .onChange(of: vm.notchState) { _, state in
            if state == .closed { selectedDate = Date.now }
        }
    }
}

struct DailyTodoList: View {
    let selectedDate: Date
    @ObservedObject private var store = TodoStore.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealedTodoID: UUID?
    @State private var hoveringBottom = false
    @State private var drafts: [String: String] = [:]
    @FocusState private var inputFocused: Bool

    private var dayKey: String { TodoStore.dayKey(for: selectedDate) }
    private var draft: Binding<String> {
        Binding(get: { drafts[dayKey, default: ""] }, set: { drafts[dayKey] = $0 })
    }
    private var dateLabel: String {
        let parts = Calendar.current.dateComponents([.month, .day], from: selectedDate)
        return "\(parts.month!)月\(parts.day!)日"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    if store.todos(on: selectedDate).isEmpty {
                        Text(
                            Calendar.current.isDateInToday(selectedDate)
                                ? "今日暂无待办" : "\(dateLabel)暂无待办"
                        )
                        .font(.caption)
                        .foregroundStyle(Color(white: 0.65))
                        .padding(.top, 8)
                    }
                    ForEach(store.todos(on: selectedDate)) { todo in
                        SwipeableTodoRow(
                            todo: todo,
                            isRevealed: Binding(
                                get: { revealedTodoID == todo.id },
                                set: { revealedTodoID = $0 ? todo.id : nil }
                            ),
                            onToggle: { store.toggle(todo.id) },
                            onDelete: {
                                store.delete(todo.id)
                                revealedTodoID = nil
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, hoveringBottom ? 36 : 10)
            }
            .scrollIndicators(.hidden)

            ZStack {
                Color.black.opacity(0.001)
                HStack(spacing: 4) {
                    TextField(
                        "", text: draft,
                        prompt: Text("请记录\(dateLabel)待办事项")
                            .foregroundColor(Color(white: 0.65))
                    )
                    .font(.system(size: 11))
                    .textFieldStyle(.plain)
                    .focused($inputFocused)
                    .onSubmit(addTodo)
                    .accessibilityLabel("请记录\(dateLabel)待办事项")
                    Button(action: addTodo) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 17))
                            .foregroundStyle(Color.effectiveAccent)
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        draft.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                    .accessibilityLabel("添加待办")
                }
                .padding(.horizontal, 7)
                .frame(height: 30)
                .background(Color(white: 0.14), in: RoundedRectangle(cornerRadius: 8))
                .opacity(hoveringBottom ? 1 : 0)
                .offset(y: hoveringBottom || reduceMotion ? 0 : 4)
                .allowsHitTesting(hoveringBottom)
                .accessibilityHidden(!hoveringBottom)
            }
            .frame(height: 32)
            .contentShape(Rectangle())
            .onHover(perform: setHover)
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: hoveringBottom)
        .onChange(of: selectedDate) { _, _ in
            inputFocused = false
            revealedTodoID = nil
        }
        .onDisappear { setHover(false) }
    }

    private func setHover(_ hovering: Bool) {
        hoveringBottom = hovering
        if !hovering { inputFocused = false }
    }

    private func addTodo() {
        if store.add(draft.wrappedValue, on: selectedDate) {
            drafts[dayKey] = ""
        }
    }
}

private struct SwipeableTodoRow: View {
    let todo: DailyTodo
    @Binding var isRevealed: Bool
    let onToggle: () -> Void
    let onDelete: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Text("删除")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 26)
                    .background(.red, in: RoundedRectangle(cornerRadius: 5))
            }
            .buttonStyle(.plain)
            .opacity(isRevealed ? 1 : 0)
            .allowsHitTesting(isRevealed)
            .accessibilityHidden(!isRevealed)
            .accessibilityLabel("删除待办：\(todo.title)")

            HStack(alignment: .top, spacing: 7) {
                Image(systemName: todo.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.system(size: 14))
                    .foregroundStyle(todo.isCompleted ? Color(white: 0.55) : Color.effectiveAccent)
                Text(todo.title)
                    .font(.callout)
                    .foregroundStyle(todo.isCompleted ? Color(white: 0.55) : .white)
                    .strikethrough(todo.isCompleted)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.vertical, 3)
            .frame(minHeight: 26)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.black)
            .contentShape(Rectangle())
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(todo.title)
            .accessibilityValue(todo.isCompleted ? "已完成" : "未完成")
            .accessibilityHint("点击切换完成状态，向左滑动显示删除按钮")
            .accessibilityAction { activateRow() }
            .accessibilityAction(named: Text("显示删除按钮")) { isRevealed = true }
            .gesture(
                // Once a drag is recognized, mouse-up must never activate the row.
                // Measure in the stationary row, not the content that slides left.
                DragGesture(minimumDistance: 12, coordinateSpace: .named(todo.id))
                    .onChanged { value in
                        guard abs(value.translation.width) > abs(value.translation.height) * 1.5 else { return }
                        if value.translation.width < -20 { isRevealed = true }
                        if value.translation.width > 20 { isRevealed = false }
                    }
                    .exclusively(before: TapGesture().onEnded { activateRow() })
            )
            .offset(x: isRevealed ? -56 : 0)
        }
        .coordinateSpace(name: todo.id)
        .clipped()
        .background(TodoSwipeMonitor { isRevealed = $0 })
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: isRevealed)
    }

    private func activateRow() {
        if isRevealed { isRevealed = false } else { onToggle() }
    }
}

// Trackpad horizontal scrolling does not generate a SwiftUI DragGesture on macOS.
// Only consume horizontal events over this visible row; vertical scrolling stays native.
private struct TodoSwipeMonitor: NSViewRepresentable {
    let onSwipe: (Bool) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onSwipe: onSwipe) }
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        context.coordinator.install(on: view)
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.onSwipe = onSwipe
    }
    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.remove()
    }

    @MainActor final class Coordinator {
        var onSwipe: (Bool) -> Void
        private var monitor: Any?
        private var distance: CGFloat = 0
        private var lastEventTime: TimeInterval = 0
        init(onSwipe: @escaping (Bool) -> Void) { self.onSwipe = onSwipe }

        func install(on view: NSView) {
            monitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self, weak view] event in
                guard let self, let view, let window = view.window,
                      event.window === window,
                      view.visibleRect.contains(view.convert(event.locationInWindow, from: nil))
                else { return event }
                if event.phase == .began || event.timestamp - self.lastEventTime > 0.3 {
                    self.distance = 0
                }
                self.lastEventTime = event.timestamp
                guard abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) * 1.5 else {
                    if event.phase == .ended || event.phase == .cancelled { self.distance = 0 }
                    return event
                }
                guard event.momentumPhase.isEmpty else { return nil }
                self.distance += event.scrollingDeltaX * (event.hasPreciseScrollingDeltas ? 1 : 8)
                if abs(self.distance) >= 20 {
                    self.onSwipe(self.distance < 0)
                    self.distance = 0
                }
                return nil
            }
        }
        func remove() {
            if let monitor { NSEvent.removeMonitor(monitor) }
            monitor = nil
        }
    }
}

#Preview {
    CalendarView()
        .frame(width: 215, height: 130)
        .background(.black)
        .environmentObject(BoringViewModel())
}
