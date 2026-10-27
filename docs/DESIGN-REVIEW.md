# SoftNotch design finish review

Date: 2026-10-16. Scope: established Sapphire interface adapted to the independent SoftNotch identity.

Disposition: **ship for the scoped identity adaptation**. The reviewed evidence introduces no new visual blocker. This is not a claim of full official Sapphire feature parity or complete runtime validation.

## Evidence checked

- `PRODUCT.md`, `DESIGN.md`, `docs/UI-BRIEF.md`, and `docs/VALIDATION.md` establish preservation of the native SwiftUI/AppKit interface and the available-source boundary.
- Saved `docs/screenshots/softnotch-welcome.png`: SoftNotch name and new icon are visible within the incumbent welcome composition. The captured welcome text is English.
- Saved `docs/screenshots/softnotch-settings-zh.png`: Simplified Chinese settings retain the sidebar, grouped containers, native toggles, and control hierarchy.
- Saved `docs/screenshots/softnotch-about-zh.png`: the icon, SoftNotch name, version 1.0.0, Walter Luo personal-edition copy, local guide, explicitly labeled Sapphire source, manual-update explanation, and available-source limitation are visible.
- `scripts/generate-icon.swift` and `docs/icon-provenance.txt` identify the original vector icon geometry: dark blue-gray field, continuous aqua S ribbon, and inset notch. The icon colors are asset-specific; they do not establish a replacement interface palette.
- `SoftNotch/App Settings/SettingsPanes.swift` and the matching `en.lproj` / `zh-Hans.lproj` strings agree with the About identity and update copy. `SettingsLocalization.swift` establishes Simplified Chinese as the settings default and retains English.
- `SoftNotch/App/SoftNotchBuildFlags.swift` disables remote updates; guarded updater entry points and the manual-status pane agree with the documented policy.

## Preservation and documentation

`DESIGN.md` remains factually aligned with the implemented identity adaptation and is retained unchanged. No new global tokens, typography, layout, materials, control ordering, or motion system were introduced by this documentation finish. This is an extension of the incumbent native application, so no HTML/CSS detector or web component sidecar is applicable.

## Limits

This review inspected saved screenshots and the named source/document evidence; it did not control the live application or repeat build, test, signing, or packaging checks. Those results and their boundaries remain in `docs/VALIDATION.md`.

The screenshots support the reviewed welcome/settings/About surfaces. They do not establish pixel-by-pixel parity against a simultaneous upstream capture, complete onboarding localization, motion fidelity, active notch behavior, permission-dependent features, or multi-display and lock-screen behavior. The existing scoped ship disposition does not broaden those claims.
