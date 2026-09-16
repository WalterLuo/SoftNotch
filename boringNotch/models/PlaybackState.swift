//
//  PlaybackState.swift
//  boringNotch
//
//  Maintained by Walterluo for SoftNotch. Original attribution: docs/UPSTREAM_ATTRIBUTIONS.md.
//

import Foundation

enum RepeatMode: Int, Codable {
    case off = 1
    case one = 2
    case all = 3
}

struct PlaybackState {
    var bundleIdentifier: String
    var isPlaying: Bool = false
    var title: String = "I'm Handsome"
    var artist: String = "Me"
    var album: String = "Self Love"
    var currentTime: Double = 0
    var duration: Double = 0
    var playbackRate: Double = 1
    var isShuffled: Bool = false
    var repeatMode: RepeatMode = .off
    var lastUpdated: Date = Date.distantPast
    var artwork: Data?
    var volume: Double = 0.5
    var isFavorite: Bool = false
}

extension PlaybackState: Equatable {
    static func == (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        return lhs.bundleIdentifier == rhs.bundleIdentifier
            && lhs.isPlaying == rhs.isPlaying
            && lhs.title == rhs.title
            && lhs.artist == rhs.artist
            && lhs.album == rhs.album
            && lhs.currentTime == rhs.currentTime
            && lhs.duration == rhs.duration
            && lhs.isShuffled == rhs.isShuffled
            && lhs.repeatMode == rhs.repeatMode
            && lhs.artwork == rhs.artwork
            && lhs.isFavorite == rhs.isFavorite
    }
}

struct NowPlayingUpdate: Codable {
    let payload: NowPlayingPayload
    let diff: Bool?
}

struct NowPlayingPayload: Codable {
    let title: String?
    let artist: String?
    let album: String?
    let duration: Double?
    let elapsedTime: Double?
    let shuffleMode: Int?
    let repeatMode: Int?
    let artworkData: String?
    let timestamp: String?
    let playbackRate: Double?
    let playing: Bool?
    let parentApplicationBundleIdentifier: String?
    let bundleIdentifier: String?
    let volume: Double?
}

extension NowPlayingUpdate {
    /// Production uses full snapshots. Also accepts deltas for adapter compatibility.
    func applying(to previous: PlaybackState, now: Date = Date()) -> PlaybackState {
        let source = payload.parentApplicationBundleIdentifier ?? payload.bundleIdentifier
        let preservesPrevious = diff == true && (source == nil || source == previous.bundleIdentifier)
        var state = preservesPrevious ? previous : PlaybackState(bundleIdentifier: source ?? "")
        state.bundleIdentifier = source ?? (preservesPrevious ? previous.bundleIdentifier : "")
        state.title = payload.title ?? (preservesPrevious ? previous.title : "")
        state.artist = payload.artist ?? (preservesPrevious ? previous.artist : "")
        state.album = payload.album ?? (preservesPrevious ? previous.album : "")
        state.duration = max(0, payload.duration ?? (preservesPrevious ? previous.duration : 0))
        state.isPlaying = payload.playing ?? (preservesPrevious ? previous.isPlaying : false)
        state.playbackRate = state.isPlaying
            ? (payload.playbackRate ?? (preservesPrevious && previous.isPlaying ? previous.playbackRate : 1))
            : 0

        let formatter = ISO8601DateFormatter()
        let timestamp = payload.timestamp.flatMap { value -> Date? in
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: value) { return date }
            formatter.formatOptions = [.withInternetDateTime]
            return formatter.date(from: value)
        }
        // Re-anchor deltas at their timestamp so pause/resume cannot double-count time.
        state.lastUpdated = timestamp ?? now
        if let elapsed = payload.elapsedTime {
            state.currentTime = max(0, elapsed)
        } else if preservesPrevious {
            let elapsed = previous.isPlaying
                ? max(0, state.lastUpdated.timeIntervalSince(previous.lastUpdated)) * previous.playbackRate
                : 0
            state.currentTime = max(0, previous.currentTime + elapsed)
        } else {
            state.currentTime = 0
        }
        if state.duration > 0 { state.currentTime = min(state.currentTime, state.duration) }
        state.isShuffled = payload.shuffleMode.map { $0 != 1 } ?? (preservesPrevious ? previous.isShuffled : false)
        state.repeatMode = payload.repeatMode.flatMap(RepeatMode.init(rawValue:)) ?? (preservesPrevious ? previous.repeatMode : .off)
        if let artwork = payload.artworkData {
            state.artwork = Data(base64Encoded: artwork.trimmingCharacters(in: .whitespacesAndNewlines))
        } else if !preservesPrevious {
            state.artwork = nil
        }
        state.volume = payload.volume ?? (preservesPrevious ? previous.volume : 0.5)
        return state
    }
}
