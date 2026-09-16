import AppKit
import Combine
import Defaults
import ImageIO

extension Notification.Name {
    static let screenshotAddedToShelf = Notification.Name("screenshotAddedToShelf")
}

@MainActor
final class ScreenshotManager: NSObject, ObservableObject {
    static let shared = ScreenshotManager()
    @Published private(set) var isCapturing = false
    @Published var errorMessage: String?
    private let query = NSMetadataQuery()
    private let startedAt = Date()
    private var seenPaths: Set<String> = []
    private var process: Process?
    private var hiddenWindows: [NSWindow] = []
    private var holdOpenUntil = Date.distantPast
    var preventsClosing: Bool { isCapturing || Date() < holdOpenUntil }

    func startMonitoring() {
        guard !query.isStarted else { return }
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture == 1 AND kMDItemFSCreationDate >= %@", startedAt as NSDate)
        var scopes: [Any] = [NSMetadataQueryUserHomeScope]
        if let location = CFPreferencesCopyAppValue("location" as CFString, "com.apple.screencapture" as CFString) as? String {
            scopes.append((location as NSString).expandingTildeInPath)
        }
        query.searchScopes = scopes
        query.notificationBatchingInterval = 0.4
        NotificationCenter.default.addObserver(self, selector: #selector(foundScreenshots), name: .NSMetadataQueryDidFinishGathering, object: query)
        NotificationCenter.default.addObserver(self, selector: #selector(foundScreenshots), name: .NSMetadataQueryDidUpdate, object: query)
        query.start()
    }

    @objc private func foundScreenshots() {
        query.disableUpdates()
        let urls = query.results.compactMap { result -> URL? in
            guard let item = result as? NSMetadataItem,
                  let path = item.value(forAttribute: NSMetadataItemPathKey) as? String,
                  !seenPaths.contains(path) else { return nil }
            seenPaths.insert(path)
            return URL(fileURLWithPath: path)
        }
        query.enableUpdates()
        for url in urls {
            Task { await importSystemScreenshot(url) }
        }
    }

    private func importSystemScreenshot(_ url: URL) async {
        // Spotlight can announce the file before the image has finished writing.
        for _ in 0..<8 {
            if let data = try? Data(contentsOf: url),
               let source = CGImageSourceCreateWithData(data as CFData, nil),
               CGImageSourceGetStatus(source) == .statusComplete,
               let copy = await TemporaryFileStorageService.shared.createTempFile(for: .data(data, suggestedName: url.lastPathComponent)) {
                do { try addToShelf(copy, screenUUID: nil) }
                catch {
                    TemporaryFileStorageService.shared.removeTemporaryFileIfNeeded(at: copy)
                    errorMessage = "截屏暂存失败：\(error.localizedDescription)"
                }
                return
            }
            try? await Task.sleep(for: .milliseconds(500))
        }
        errorMessage = "无法读取新截屏，请检查截屏文件及文件夹访问权限。"
    }

    func captureRegion(screenUUID: String?) {
        guard !isCapturing else { return }
        guard CGPreflightScreenCaptureAccess() || CGRequestScreenCaptureAccess() else {
            errorMessage = "请在系统设置 → 隐私与安全性 → 屏幕与系统音频录制中允许 SoftNotch，然后重试截屏。"
            return
        }
        isCapturing = true
        hiddenWindows = NSApp.windows.filter {
            ($0 is BoringNotchWindow || $0 is BoringNotchSkyLightWindow) && $0.isVisible
        }
        hiddenWindows.forEach { $0.orderOut(nil) }
        Task {
            // Let the hidden panel disappear before macOS snapshots the screen.
            try? await Task.sleep(for: .milliseconds(250))
            let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
            let file = directory.appendingPathComponent("截屏 \(formatter.string(from: Date())).png")
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                let capture = Process()
                capture.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
                capture.arguments = ["-i", "-s", "-x", "-t", "png", file.path]
                seenPaths.insert(file.path)
                process = capture
                let status: Int32 = try await withCheckedThrowingContinuation { continuation in
                    capture.terminationHandler = { finished in
                        continuation.resume(returning: finished.terminationStatus)
                    }
                    do { try capture.run() }
                    catch { continuation.resume(throwing: error) }
                }
                restoreWindows()
                // Escape cancels without creating a file. Do not add an empty shelf item.
                if FileManager.default.fileExists(atPath: file.path) {
                    guard status == 0, let image = NSImage(contentsOf: file), image.isValid else {
                        throw NSError(domain: "Screenshot", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "截屏文件未完整生成"])
                    }
                    try addToShelf(file, screenUUID: screenUUID)
                } else {
                    try? FileManager.default.removeItem(at: directory)
                }
            } catch {
                restoreWindows()
                try? FileManager.default.removeItem(at: directory)
                errorMessage = "截屏失败：\(error.localizedDescription)"
            }
        }
    }

    private func restoreWindows() {
        hiddenWindows.forEach { $0.orderFrontRegardless() }
        hiddenWindows.removeAll()
        process = nil
        isCapturing = false
    }

    private func addToShelf(_ url: URL, screenUUID: String?) throws {
        let item = ShelfItem(kind: .file(bookmark: try Bookmark(url: url).data), isTemporary: true)
        ShelfStateViewModel.shared.add([item])
        holdOpenUntil = Date().addingTimeInterval(4)
        BoringViewCoordinator.shared.currentView = .shelf
        NotificationCenter.default.post(name: .screenshotAddedToShelf, object: screenUUID ?? BoringViewCoordinator.shared.selectedScreenUUID)
    }
}
