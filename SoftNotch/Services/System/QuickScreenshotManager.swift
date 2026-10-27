import AppKit
import Combine

/// Uses macOS's region picker and writes the image directly to the system clipboard.
@MainActor
final class QuickScreenshotManager: ObservableObject {
    static let shared = QuickScreenshotManager()
    @Published private(set) var isCapturing = false
    private var captureProcess: Process?
    private var hiddenWindows: [NSWindow] = []

    private init() {}

    func captureRegion() {
        guard !isCapturing else { return }
        isCapturing = true
        hiddenWindows = (NSApp.delegate as? AppDelegate)?.notchWindows.filter(\.isVisible) ?? []
        hiddenWindows.forEach { $0.orderOut(nil) }

        Task { @MainActor in
            // Let WindowServer remove the notch before the system picker snapshots the screen.
            try? await Task.sleep(for: .milliseconds(150))
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
            // Interactive region only, clipboard output, silent, native error presentation.
            process.arguments = ["-i", "-s", "-c", "-x", "-d"]
            process.terminationHandler = { [weak self] _ in
                Task { @MainActor in self?.finishCapture() }
            }
            captureProcess = process
            do {
                try process.run()
            } catch {
                finishCapture()
                let alert = NSAlert()
                alert.messageText = SettingsLocalization.string("Unable to Start Screenshot")
                alert.informativeText = SettingsLocalization.string("Please try again, or use Control-Command-Shift-4 to capture an area to the clipboard.")
                alert.addButton(withTitle: SettingsLocalization.string("OK"))
                alert.runModal()
            }
        }
    }

    private func finishCapture() {
        // Cancellation never clears or rewrites the user's existing clipboard.
        captureProcess = nil
        let currentWindows = (NSApp.delegate as? AppDelegate)?.notchWindows ?? []
        for window in hiddenWindows where currentWindows.contains(where: { $0 === window }) {
            window.orderFront(nil)
        }
        hiddenWindows.removeAll()
        isCapturing = false
        // Do not activate SoftNotch: the destination app must remain ready for Command-V.
    }
}
