#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
test_dir=$(mktemp -d /tmp/boringnotch-tests.XXXXXX)
trap 'rm -rf "$test_dir"' EXIT
xcrun swiftc -module-cache-path /tmp/boringnotch-swift-cache \
  boringNotch/models/PlaybackState.swift \
  boringNotch/MediaControllers/MediaControllerProtocol.swift \
  boringNotch/MediaControllers/NowPlayingController.swift \
  boringNotch/helpers/AppleScriptHelper.swift \
  tests/NowPlayingStateTests.swift -o "$test_dir/tests"
"$test_dir/tests"
