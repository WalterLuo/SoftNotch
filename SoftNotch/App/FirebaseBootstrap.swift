//
//  FirebaseBootstrap.swift
//  SoftNotch
//
//  Created by Shariq Charolia on 2026-09-14

import FirebaseAppCheck
import FirebaseCore

@MainActor
enum FirebaseBootstrap {
    private(set) static var isConfigured = false

    static func configureIfNeeded() {
        guard SoftNotchBuildFlags.analyticsEnabled, !isConfigured else { return }
        // The public source ships an empty Firebase configuration. Do not
        // initialize cloud services with placeholder credentials in local builds.
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path),
              let apiKey = options.apiKey, !apiKey.isEmpty,
              !options.googleAppID.contains("000000000000") else { return }
        #if DEBUG
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(DeviceCheckProviderFactory())
        #endif
        FirebaseApp.configure(options: options)
        isConfigured = true
    }
}