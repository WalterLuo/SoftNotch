#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
ARGS=(-project SoftNotch.xcodeproj -scheme SoftNotch -configuration Release
      -destination 'platform=macOS,arch=arm64' -derivedDataPath "$ROOT/build/DerivedData"
      CODE_SIGNING_ALLOWED=NO ENABLE_TESTABILITY=YES)
if [[ -n "${SOFTNOTCH_PACKAGE_CACHE:-}" ]]; then
  ARGS+=(-clonedSourcePackagesDirPath "$SOFTNOTCH_PACKAGE_CACHE" -disableAutomaticPackageResolution -skipPackageUpdates)
fi
mkdir -p build
xcodebuild "${ARGS[@]}" "${@:-build}"
