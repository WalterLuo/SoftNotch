#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
bash tests/run-now-playing-tests.sh
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/softnotch-todos.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT
xcrun swiftc -module-cache-path "$test_dir/modules" \
  boringNotch/models/TodoStore.swift tests/DailyTodoTests.swift -o "$test_dir/tests"
"$test_dir/tests"
