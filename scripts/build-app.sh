#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_CONFIGURATION="${1:-release}"
APP_DIR="$PROJECT_DIR/dist/Shi.app"
SOURCE_PACKAGES_DIR="$PROJECT_DIR/build/SourcePackages"
TEMP_ROOT="${TMPDIR:-/tmp}"
TEMP_ROOT="${TEMP_ROOT%/}"
DERIVED_DATA_DIR="$(mktemp -d "$TEMP_ROOT/Shi-build.XXXXXX")"
CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY:--}"

cleanup_derived_data() {
    case "$DERIVED_DATA_DIR" in
        "$TEMP_ROOT"/Shi-build.*)
            /bin/rm -rf "$DERIVED_DATA_DIR"
            ;;
        *)
            print -u2 "Refusing to remove unexpected build directory: $DERIVED_DATA_DIR"
            ;;
    esac
}

trap cleanup_derived_data EXIT

case "$APP_DIR" in
    "$PROJECT_DIR/dist/Shi.app") ;;
    *)
        print -u2 "Refusing to build outside the project dist directory."
        exit 1
        ;;
esac

case "$BUILD_CONFIGURATION" in
    debug)
        XCODE_CONFIGURATION="Debug"
        ;;
    release)
        XCODE_CONFIGURATION="Release"
        ;;
    *)
        print -u2 "Build configuration must be debug or release."
        exit 1
        ;;
esac

mkdir -p "$PROJECT_DIR/dist" "$SOURCE_PACKAGES_DIR"

SIGNING_ARGS=(
    CODE_SIGN_STYLE=Manual
    CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY"
)
if [[ "$CODE_SIGN_IDENTITY" != "-" ]]; then
    SIGNING_ARGS+=(OTHER_CODE_SIGN_FLAGS="--timestamp")
fi

xcodebuild \
    -project "$PROJECT_DIR/Shi.xcodeproj" \
    -scheme Shi \
    -configuration "$XCODE_CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA_DIR" \
    -clonedSourcePackagesDirPath "$SOURCE_PACKAGES_DIR" \
    -destination "generic/platform=macOS" \
    ARCHS="arm64 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
    "${SIGNING_ARGS[@]}" \
    build

BUILT_APP="$DERIVED_DATA_DIR/Build/Products/$XCODE_CONFIGURATION/Shi.app"
if [[ ! -d "$BUILT_APP" ]]; then
    print -u2 "Xcode completed without producing Shi.app."
    exit 1
fi

APP_BINARY="$BUILT_APP/Contents/MacOS/Shi"
SPARKLE_FRAMEWORK="$BUILT_APP/Contents/Frameworks/Sparkle.framework"
SPARKLE_VERSION_DIR="$SPARKLE_FRAMEWORK/Versions/B"
if [[ ! -d "$SPARKLE_VERSION_DIR" ]]; then
    print -u2 "The embedded Sparkle.framework is incomplete."
    exit 1
fi

# Xcode preserves Sparkle's nested signatures when embedding the binary
# package. Every executable must be signed by the same identity as the host
# app or Hardened Runtime library validation will reject Sparkle at launch.
SPARKLE_CODE_SIGN_OPTIONS=(--options runtime)
APP_CODE_SIGN_OPTIONS=(--entitlements "$PROJECT_DIR/Shi/Shi.entitlements")
if [[ "$CODE_SIGN_IDENTITY" != "-" ]]; then
    SPARKLE_CODE_SIGN_OPTIONS+=(--timestamp)
    APP_CODE_SIGN_OPTIONS+=(--options runtime --timestamp)
fi

/usr/bin/codesign --force --sign "$CODE_SIGN_IDENTITY" \
    "${SPARKLE_CODE_SIGN_OPTIONS[@]}" \
    "$SPARKLE_VERSION_DIR/XPCServices/Installer.xpc"
/usr/bin/codesign --force --sign "$CODE_SIGN_IDENTITY" \
    "${SPARKLE_CODE_SIGN_OPTIONS[@]}" \
    --preserve-metadata=entitlements \
    "$SPARKLE_VERSION_DIR/XPCServices/Downloader.xpc"
/usr/bin/codesign --force --sign "$CODE_SIGN_IDENTITY" \
    "${SPARKLE_CODE_SIGN_OPTIONS[@]}" \
    "$SPARKLE_VERSION_DIR/Autoupdate"
/usr/bin/codesign --force --sign "$CODE_SIGN_IDENTITY" \
    "${SPARKLE_CODE_SIGN_OPTIONS[@]}" \
    "$SPARKLE_VERSION_DIR/Updater.app"
/usr/bin/codesign --force --sign "$CODE_SIGN_IDENTITY" \
    "${SPARKLE_CODE_SIGN_OPTIONS[@]}" \
    "$SPARKLE_FRAMEWORK"
/usr/bin/codesign --force --sign "$CODE_SIGN_IDENTITY" \
    "${APP_CODE_SIGN_OPTIONS[@]}" \
    "$BUILT_APP"

BUILT_ARCHITECTURES="$(/usr/bin/lipo -archs "$APP_BINARY")"
if [[ " $BUILT_ARCHITECTURES " != *" arm64 "* \
    || " $BUILT_ARCHITECTURES " != *" x86_64 "* ]]; then
    print -u2 "Shi must contain arm64 and x86_64; found: $BUILT_ARCHITECTURES"
    exit 1
fi

/usr/bin/codesign --verify --deep --strict --verbose=2 "$BUILT_APP"

APP_SIGNATURE_DETAILS="$(/usr/bin/codesign -dvv "$BUILT_APP" 2>&1)"
if [[ "$CODE_SIGN_IDENTITY" == "-" ]]; then
    if [[ "$APP_SIGNATURE_DETAILS" == *"runtime"* ]]; then
        print -u2 "Ad-hoc builds must not enable library validation without a Team ID."
        exit 1
    fi
elif [[ "$APP_SIGNATURE_DETAILS" != *"runtime"* ]]; then
    print -u2 "Developer ID builds must enable Hardened Runtime."
    exit 1
fi

# Do not replace the last usable artifact until building, nested signing, and
# verification have all succeeded.
if [[ -d "$APP_DIR" ]]; then
    /bin/rm -rf "$APP_DIR"
fi
/usr/bin/ditto "$BUILT_APP" "$APP_DIR"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$APP_DIR"

print "$APP_DIR"
