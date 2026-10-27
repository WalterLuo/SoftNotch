import Foundation

/// Public-source builds only expose implemented features. This does not grant entitlements.
enum BuildAvailability {
    #if SOFTNOTCH_FULL_BUILD
    static let full = true
    #else
    static let full = false
    #endif
}

extension SettingsSection {
    var isAvailableInBuild: Bool {
        if BuildAvailability.full { return true }
        switch self {
        case .keyboardShortcuts, .continuity, .emoji, .mouse, .monitoring,
             .archives, .appLock, .dockLayouts, .mediaOptimizer, .storage,
             .intelligence, .sports, .finance: return false
        default: return true
        }
    }
}

extension WidgetType {
    var isAvailableInBuild: Bool {
        BuildAvailability.full || (requiredPremiumFeature == nil && self != .agent)
    }
}

extension LiveActivityType {
    var isAvailableInBuild: Bool {
        BuildAvailability.full || requiredPremiumFeature == nil
    }
}

extension NotchButtonType {
    var isAvailableInBuild: Bool {
        BuildAvailability.full || (self != .intelligence && self != .intelligenceLive)
    }
}

// Also reject restored navigation into removed pages from an older installation.
extension NotchWidgetMode {
    var isAvailableInBuild: Bool {
        if BuildAvailability.full { return true }
        switch self {
        case .geminiApiKeysMissing, .sportsPlayer, .financePlayer, .multiAudioApp8D,
             .multiAudioAppSurround, .agentS, .blipHub, .circleToSearch,
             .storageDetailView, .continuityDetail, .continuityActivityDetail: return false
        default: return true
        }
    }
}
