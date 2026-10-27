import Foundation

/// Settings language is deliberately independent from the macOS language and
/// from Codable setting values: switching languages never changes saved IDs.
enum SettingsLocalization {
    static let preferenceKey = "softnotch.settingsLanguage"
    static let defaultLanguage = "zh-Hans"

    static var language: String {
        let saved = UserDefaults.standard.string(forKey: preferenceKey)
        return saved == "en" || saved == "zh-Hans" ? saved! : defaultLanguage
    }

    static func string(_ key: String, language: String? = nil, bundle: Bundle = .main) -> String {
        let code = language ?? self.language
        guard let path = bundle.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return key }
        return bundle.localizedString(forKey: key, value: key, table: "Localizable")
    }
}
