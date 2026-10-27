# SoftNotch product context

Owner: Walter Luo. Native macOS notch utility, forked from the available local Sapphire source. Repository: [WalterLuo/SoftNotch](https://github.com/WalterLuo/SoftNotch).

The user's explicit brief is to reproduce Sapphire as their own program named softnotch. Preserve the incumbent interface, animations, layout, supported feature implementations, and English/Simplified Chinese settings. Do not introduce a new visual world or rebuild as a web app.

Current scope: independent Xcode project, app and helper identities, preferences/data namespaces, icon, branding and local build/sign/package workflow. The source version remains 1.0.0, build 20261016.1. Default language is Simplified Chinese. Never use the original updater to install Sapphire over SoftNotch. Keep source authorship, attribution and AGPL license intact.

The quick screenshot action captures a selected region to the clipboard. Opening the expanded notch panel resets its calendar selection to the current local day; while the panel stays open, users can browse other dates. Reopening reads the current date and calendar again, including after a missed day-change notification or a time-zone change.

The public source omits some official implementations. Some unsupported feature entries are hidden; other implementations remain stubs. Describe feature parity only at the scope actually verified in [docs/VALIDATION.md](docs/VALIDATION.md).

The repository's earlier boring.notch-derived SoftNotch is a different implementation preserved in Git history. The current Sapphire-derived app uses `com.walterluo.softnotch`, its own helper identity and data namespaces. It does not automatically migrate data from Sapphire or the older SoftNotch. See [README.md](README.md) for the current feature and compatibility overview and [docs/BUILDING.md](docs/BUILDING.md) for development.
