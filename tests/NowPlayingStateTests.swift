import Foundation

@main
struct NowPlayingStateTests {
    static func main() async throws {
        let now = Date(timeIntervalSince1970: 1000)
        func update(_ json: String, _ previous: PlaybackState = PlaybackState(bundleIdentifier: ""), at date: Date? = nil) throws -> PlaybackState {
            try JSONDecoder().decode(NowPlayingUpdate.self, from: Data(json.utf8)).applying(to: previous, now: date ?? now)
        }
        let playing = try update(#"{"payload":{"bundleIdentifier":"com.netease.163music","title":"乡下的老鼠","artist":"罗言","duration":139,"elapsedTime":20,"playing":true,"artworkData":"AQID"},"diff":false}"#)
        precondition(playing.title == "乡下的老鼠" && playing.isPlaying && playing.playbackRate == 1)
        precondition(playing.artwork == Data([1, 2, 3]))
        let paused = try update(#"{"payload":{"playing":false},"diff":true}"#, playing, at: now.addingTimeInterval(5))
        precondition(paused.currentTime == 25 && paused.playbackRate == 0 && paused.artwork == playing.artwork)
        let resumed = try update(#"{"payload":{"playing":true},"diff":true}"#, paused, at: now.addingTimeInterval(30))
        precondition(resumed.currentTime == 25 && resumed.playbackRate == 1)
        let qq = try update(#"{"payload":{"bundleIdentifier":"com.tencent.QQMusic","title":"新歌","playing":true},"diff":true}"#, playing)
        precondition(qq.title == "新歌" && qq.artist.isEmpty && qq.artwork == nil && qq.currentTime == 0)
        let cleared = try update(#"{"payload":{},"diff":false}"#, playing)
        precondition(cleared.bundleIdentifier.isEmpty && cleared.title.isEmpty && cleared.artwork == nil && !cleared.isPlaying)
        let removedArt = try update(#"{"payload":{"bundleIdentifier":"com.netease.163music","title":"新歌","artworkData":null},"diff":false}"#, playing)
        precondition(removedArt.artwork == nil)
        let timestamp = try update(#"{"payload":{"timestamp":"2026-09-16T08:36:49.125Z","elapsedTime":10,"playing":true}}"#)
        precondition(abs(timestamp.lastUpdated.timeIntervalSince1970 - 1789547809.125) < 0.001)
        let parent = try update(#"{"payload":{"bundleIdentifier":"helper","parentApplicationBundleIdentifier":"com.netease.163music"}}"#)
        precondition(parent.bundleIdentifier == "com.netease.163music")
        let handler = JSONLinesPipeHandler()
        let pipe = await handler.getPipe()
        let received = ReceivedUpdates()
        let reader = Task {
            await handler.readJSONLines(as: NowPlayingUpdate.self) { await received.append($0) }
        }
        let bytes = Data((#"{"payload":{"title":"网易云音乐"}}"# + "\n").utf8)
        // Force a pipe boundary inside the first Chinese UTF-8 character.
        let split = bytes.firstIndex(of: 0xE7)! + 1
        try pipe.fileHandleForWriting.write(contentsOf: bytes[..<split])
        try await Task.sleep(for: .milliseconds(100))
        try pipe.fileHandleForWriting.write(contentsOf: bytes[split...])
        try pipe.fileHandleForWriting.close()
        await reader.value
        let titles = await received.titles
        precondition(titles == ["网易云音乐"])
        await handler.close()
        print("PASS: NetEase metadata, artwork, pause/resume, source switching, clearing, timestamps and split UTF-8 pipe reads")
    }
}

private actor ReceivedUpdates {
    var titles: [String] = []
    func append(_ update: NowPlayingUpdate) { titles.append(update.payload.title ?? "") }
}
