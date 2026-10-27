import Foundation
import XCTest
@testable import SoftNotch

final class SoftNotchIdentityTests: XCTestCase {
    func testBuiltApplicationHasIndependentIdentityAndScheme() throws {
        let bundle = Bundle(for: SettingsModel.self)
        XCTAssertEqual(bundle.bundleIdentifier, "com.walterluo.softnotch")
        let types = try XCTUnwrap(bundle.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]])
        let schemes = types.flatMap { $0["CFBundleURLSchemes"] as? [String] ?? [] }
        XCTAssertTrue(schemes.contains("softnotch"))
        XCTAssertFalse(schemes.contains("sapphire"))
        let guide = try XCTUnwrap(bundle.url(forResource: "SoftNotch-Guide", withExtension: "txt"))
        XCTAssertTrue(try String(contentsOf: guide, encoding: .utf8).contains("AGPL"))
    }

    @MainActor
    func testManualAndPeriodicChecksCannotActivateUpstreamUpdater() {
        let checker = UpdateChecker.shared
        checker.checkForUpdates()
        checker.checkForBetaUpdates()
        checker.checkForUpdatesMatchingCurrentChannel()
        checker.startPeriodicChecks(interval: 1)
        XCTAssertEqual(checker.status, .upToDate)
        XCTAssertNil(checker.lastCheckAttemptAt)
        XCTAssertNil(checker.nextScheduledCheckAt)
        XCTAssertNil(checker.releaseNotesURL)
        checker.stopPeriodicChecks()
    }

    @MainActor
    func testDefaultsDisableRemoteUpdatesAndAnalytics() {
        let settings = Settings()
        XCTAssertFalse(settings.automaticUpdateChecksEnabled)
        XCTAssertFalse(settings.automaticallyDownloadSoftNotchUpdates)
        XCTAssertFalse(settings.googleAnalyticsEnabled)
        XCTAssertFalse(SoftNotchBuildFlags.remoteUpdatesEnabled)
        XCTAssertFalse(SoftNotchBuildFlags.analyticsEnabled)
        FirebaseBootstrap.configureIfNeeded()
        XCTAssertFalse(FirebaseBootstrap.isConfigured)
        XCTAssertEqual(SettingsLocalization.preferenceKey, "softnotch.settingsLanguage")
        XCTAssertEqual(SettingsLocalization.defaultLanguage, "zh-Hans")
    }

    func testBrandingLocalizesInBothLanguages() {
        let key = "SoftNotch Personal Edition"
        XCTAssertEqual(SettingsLocalization.string(key, language: "en"), key)
        XCTAssertEqual(SettingsLocalization.string(key, language: "zh-Hans"), "SoftNotch 个人版")
    }
}
