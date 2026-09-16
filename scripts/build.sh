#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/softnotch-build.XXXXXX")
trap 'rm -rf "$build_dir"' EXIT
xcodebuild -project boringNotch.xcodeproj -scheme boringNotch \
  -configuration Release -destination 'generic/platform=macOS' \
  -derivedDataPath "$build_dir/DerivedData" \
  -clonedSourcePackagesDirPath "${SOFTNOTCH_PACKAGES_DIR:-$build_dir/Packages}" \
  -onlyUsePackageVersionsFromResolvedFile \
  CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=NO build
app="$build_dir/DerivedData/Build/Products/Release/SoftNotch.app"
test -d "$app"
# Local ad-hoc signing requires no Apple developer account or certificate.
codesign --force --deep --sign - "$app"
codesign --verify --deep --strict "$app"
version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist")
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo 'Invalid version' >&2; exit 1; }
mkdir -p dist "$build_dir/dmg"
ditto --norsrc "$app" "$build_dir/dmg/SoftNotch.app"
ln -s /Applications "$build_dir/dmg/Applications"
cp LICENSE THIRD_PARTY_LICENSES "$build_dir/dmg/"
hdiutil create -volname "SoftNotch $version" -srcfolder "$build_dir/dmg" \
  -ov -format UDZO "dist/SoftNotch-$version-arm64.dmg"
ditto -c -k --sequesterRsrc --keepParent "$app" "dist/SoftNotch-$version-arm64.zip"
(cd dist && shasum -a 256 "SoftNotch-$version-arm64.dmg" "SoftNotch-$version-arm64.zip" > SHA256SUMS.txt)
printf 'SoftNotch %s · Apple Silicon · macOS 14+\nAd-hoc signed; not Apple notarized.\n' "$version" > dist/BUILD-INFO.txt
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  cat dist/BUILD-INFO.txt >> "$GITHUB_STEP_SUMMARY"
fi
