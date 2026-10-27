# Contributing to SoftNotch

SoftNotch is Walter Luo's personal macOS notch utility, based on the available Sapphire source. Questions, bug reports and pull requests for this version belong in [WalterLuo/SoftNotch](https://github.com/WalterLuo/SoftNotch).

## Development

Start with [README.md](README.md) and the [build guide](docs/BUILDING.md). Open `SoftNotch.xcodeproj` in a full Xcode installation and use the `SoftNotch` scheme. The build script targets Apple Silicon / arm64 with a macOS 14.6 deployment target; see the build guide for newer bundled-framework requirements and the verified toolchain.

```sh
scripts/build.sh
python3 scripts/verify-branding.py
```

Run the tests relevant to your change and include the exact commands and results in the pull request. See [validation records](docs/VALIDATION.md) for the distinction between compilation, automated tests and live feature checks. Permission-dependent or device-dependent behavior needs a separate runtime check.

## Reporting an issue

Search [existing issues](https://github.com/WalterLuo/SoftNotch/issues) before opening a new one. Include:

- The source commit or app version/build, macOS version and Mac architecture.
- Reproduction steps, expected behavior and actual behavior.
- Relevant permissions, connected devices or service configuration.
- Redacted logs or screenshots when useful; for build failures, include the Xcode version and build command.

State whether you are using the current Sapphire-derived implementation or the older boring.notch-derived SoftNotch. They have different project files and data identities; the current app does not migrate the older version's data.

For a feature request, describe the intended behavior and a concrete use case. Report vulnerabilities through the process in [SECURITY.md](SECURITY.md).

## Submitting changes

- Keep changes focused and explain their user-visible effect.
- Preserve the existing SwiftUI/AppKit interface, control order and animations unless the change explicitly addresses them.
- Add matching English and Simplified Chinese localization entries for new interface text.
- Keep the app/helper identities independent from Sapphire. Do not enable upstream update installation or analytics as an incidental change.
- Exclude credentials, signing keys, local user settings and generated build products.
- Update the relevant documentation when behavior, build steps or limitations change.

Contributions must be compatible with the repository's [GNU AGPL v3 license](LICENSE). Submit only work you have the right to contribute, preserve existing author and license notices, and identify the source and license of any third-party material. The inherited `CLA.md` refers to an MIT license; signing that upstream document is not a submission requirement for this SoftNotch repository.

Please follow the [Code of Conduct](CODE_OF_CONDUCT.md).
