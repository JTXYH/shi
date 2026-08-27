#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMP_ROOT="${TMPDIR:-/tmp}"
TEMP_ROOT="${TEMP_ROOT%/}"
TEST_BINARY="$(mktemp "$TEMP_ROOT/Shi-language-tests.XXXXXX")"
MODULE_CACHE="$(mktemp -d "$TEMP_ROOT/Shi-language-module-cache.XXXXXX")"

cleanup_test_artifacts() {
    case "$TEST_BINARY" in
        "$TEMP_ROOT"/Shi-language-tests.*)
            /bin/rm -f "$TEST_BINARY"
            ;;
        *)
            print -u2 "Refusing to remove unexpected test binary: $TEST_BINARY"
            ;;
    esac

    case "$MODULE_CACHE" in
        "$TEMP_ROOT"/Shi-language-module-cache.*)
            /bin/rm -rf "$MODULE_CACHE"
            ;;
        *)
            print -u2 "Refusing to remove unexpected module cache: $MODULE_CACHE"
            ;;
    esac
}

trap cleanup_test_artifacts EXIT

xcrun swiftc \
    -module-cache-path "$MODULE_CACHE" \
    "$PROJECT_DIR/Shi/Localization.swift" \
    "$PROJECT_DIR/Tests/LanguageResolutionSmoke.swift" \
    -o "$TEST_BINARY"

"$TEST_BINARY"
