#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
SOURCE="$ROOT/build/DerivedData/Build/Products/Release/SoftNotch.app"
[[ -d "$SOURCE" ]] || { echo 'Run scripts/build.sh first.' >&2; exit 1; }
mkdir -p dist
# Sign outside cloud-synchronized Documents: FileProvider can re-add FinderInfo
# to bundles there even immediately after codesign removes it.
STAGE="$(mktemp -d /private/tmp/softnotch-package.XXXXXX)"
trap 'rm -rf "$STAGE"' EXIT
APP="$STAGE/SoftNotch.app"
ditto --norsrc --noextattr --noacl "$SOURCE" "$APP"
python3 - "$APP" <<'PY'
import pathlib, shutil, sys
plugins = pathlib.Path(sys.argv[1]) / 'Contents/PlugIns'
for name in ['SoftNotchTests.xctest', 'SoftNotchTests.xctest.dSYM']:
    path = plugins / name
    if path.exists():
        shutil.rmtree(path)
PY
cp LICENSE "$APP/Contents/Resources/LICENSE"
cp CREDITS.md "$APP/Contents/Resources/CREDITS.md"
python3 scripts/sign-local.py "$APP"
python3 scripts/verify-branding.py "$APP"
ditto -c -k --norsrc --noextattr --keepParent "$APP" "$STAGE/SoftNotch-1.0.0-macOS-arm64.zip"
cp "$STAGE/SoftNotch-1.0.0-macOS-arm64.zip" dist/
(cd dist && shasum -a 256 SoftNotch-1.0.0-macOS-arm64.zip) > dist/SHA256SUMS
if [[ "${SOFTNOTCH_INSTALL:-0}" == "1" ]]; then
  [[ ! -e /Applications/SoftNotch.app ]] || { echo 'An installed SoftNotch already exists; back it up first.' >&2; exit 1; }
  ditto --norsrc --noextattr --noacl "$APP" /Applications/SoftNotch.app
  codesign --verify --deep --strict /Applications/SoftNotch.app
fi
