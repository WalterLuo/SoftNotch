//
//  SoftNotchBuildFlags.swift
//  SoftNotch
//
//  Created by Shariq Charolia on 2026-08-10

import Foundation

enum SoftNotchBuildFlags {
    // This fork has no release feed. Never install an upstream Sapphire release.
    static let remoteUpdatesEnabled = false
    static let analyticsEnabled = false

    static var forceOnboarding: Bool {
        #if SOFTNOTCH_FORCE_ONBOARDING
        return true
        #else
        return false
        #endif
    }
}

enum OnboardingLaunchPolicy {
    static var shouldShowOnboarding: Bool {
        if SoftNotchBuildFlags.forceOnboarding {
            return true
        }
        if UserDefaults.standard.bool(forKey: "forceOnboarding") {
            return true
        }
        return !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}