# SoftNotch native design

Mode: Operate. Visual authority is the incumbent Sapphire SwiftUI/AppKit implementation copied from the local source on 2026-10-16. Preserve its dark notch surface, rounded geometry, control order, materials, typography, spacing and animations.

The current implementation preserves the inherited layout, type, motion and color treatment. Existing SF Symbols and native SwiftUI controls remain in use. The quick screenshot action stays immediately left of the desktop pin control; it temporarily hides the notch windows while the system region picker captures to the clipboard, then restores them without activating SoftNotch.

Brand adaptation: SoftNotch display name, Walter Luo personal-edition attribution, new icon generated from original vector geometry in scripts/generate-icon.swift (dark blue-gray field, aqua S ribbon and inset notch). Settings and onboarding use the app icon. About retains an explicitly labeled link to Sapphire's original source and a local guide. Updates present a truthful manual-install status instead of inactive automatic-update controls.

The default language is Simplified Chinese, with English retained. New copy has matching en/zh-Hans localization keys. Existing data and settings identifiers use the independent SoftNotch namespace.

Calendar behavior: entering the fully expanded panel resets the selected date to today in the current local calendar. Content refreshes within an already expanded panel do not trigger that reset, so users can continue browsing another date until the panel is reopened. This changes the opening selection without changing the calendar layout or navigation controls.

The current source is published through [WalterLuo/SoftNotch](https://github.com/WalterLuo/SoftNotch), whose earlier history contains a separate boring.notch-derived implementation. That older interface is not the visual authority for this source. Saved screenshots and the dated [design review](docs/DESIGN-REVIEW.md) document the initial identity adaptation; current verification and remaining runtime checks are recorded in [docs/VALIDATION.md](docs/VALIDATION.md).
