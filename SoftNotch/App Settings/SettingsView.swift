//
//  SettingsView.swift
//  SoftNotch
//
//  Created by Shariq Charolia on 2025-07-10.
//

import SwiftUI

struct SettingsView: View {
    private let settings: SettingsModel
    @State private var editingSession: SettingsEditingSession
    @State private var selectedSection: SettingsSection? = .general
    @State private var showAccountPane = false
    @AppStorage(SettingsLocalization.preferenceKey) private var settingsLanguage = SettingsLocalization.defaultLanguage

    init(settings: SettingsModel = .shared) {
        self.settings = settings
        self._editingSession = State(initialValue: SettingsEditingSession(model: settings))
    }

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                SettingsSidebarView(
                    selectedSection: $selectedSection,
                    showAccountPane: $showAccountPane,
                    onQuit: {
                        editingSession.flushPendingSave()
                        NSApp.terminate(nil)
                    }
                )
                    .frame(width: 250)

                if BuildAvailability.full && showAccountPane {
                    AccountSettingsView()
                        .id("account-pane")
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    SettingsDetailView(selectedSection: selectedSection)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.locale, Locale(identifier: settingsLanguage))
        .environmentObject(settings)
        .environmentObject(editingSession)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: NotchConfiguration.settingsWindowCornerRadius, style: .continuous))
        .ignoresSafeArea(.container, edges: .top)
        .preferredColorScheme(.dark)
        .onReceive(NotificationCenter.default.publisher(for: .softnotchOpenAccountPane)) { _ in
            guard BuildAvailability.full else { return }
            withAnimation(.easeInOut(duration: 0.15)) {
                showAccountPane = true
                selectedSection = nil
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .softnotchSettingsWillClose)) { _ in
            editingSession.flushPendingSave()
            SystemAppFetcher.shared.releaseCachedApps()
            AppIconLoader.releaseCache()
        }
        .onDisappear {
            editingSession.flushPendingSave()
            SystemAppFetcher.shared.releaseCachedApps()
            AppIconLoader.releaseCache()
        }
    }
}