# Security Policy

This policy applies to the current Sapphire-derived SoftNotch source in [WalterLuo/SoftNotch](https://github.com/WalterLuo/SoftNotch). Include the commit or app version/build in a report so it can be distinguished from the older boring.notch-derived implementation.

## Reporting a vulnerability

If private vulnerability reporting is available for this repository, use [Report a vulnerability](https://github.com/WalterLuo/SoftNotch/security/advisories/new). Its availability depends on the repository's GitHub settings.

If that option is unavailable, open an [issue](https://github.com/WalterLuo/SoftNotch/issues/new) asking the maintainer for a private reporting channel. Keep that initial request free of exploit details, credentials, private user data and sensitive logs; provide those details only through the agreed private channel.

A useful private report includes the affected commit/build, macOS and Xcode versions where relevant, reproduction steps, expected impact and any known mitigation. Remove unrelated personal data from attachments.

## Current scope

SoftNotch is a personal project without a guaranteed security response time or a maintained release support schedule. Reports should identify whether the issue also occurs on the current source revision.

The app uses its own bundle and helper identities. Local packaging uses a local signing identity; it does not produce an Apple Developer ID notarized release. Automatic updates and Google Analytics/Crashlytics collection are disabled in this version. These settings do not establish that every inherited service, helper or device integration has been audited. See [validation records](docs/VALIDATION.md) for the verified scope.
