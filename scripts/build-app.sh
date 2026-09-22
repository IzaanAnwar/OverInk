#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

VERSION="${VERSION:-$(cat VERSION)}"
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo 'VERSION must be a semantic version such as 0.1.0.' >&2
    exit 1
fi

APP="$PROJECT_ROOT/dist/OverInk.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

BINARIES=()
for architecture in ${ARCHS:-$(uname -m)}; do
    if [[ "$architecture" != arm64 && "$architecture" != x86_64 ]]; then
        echo "Unsupported architecture: $architecture" >&2
        exit 1
    fi
    swift build "${SWIFT_ARGS[@]}" -c release --arch "$architecture"
    binary_dir="$(swift build "${SWIFT_ARGS[@]}" -c release --arch "$architecture" --show-bin-path)"
    BINARIES+=("$binary_dir/OverInk")
done

if [[ ${#BINARIES[@]} -gt 1 ]]; then
    lipo -create "${BINARIES[@]}" -output "$APP/Contents/MacOS/OverInk"
else
    cp "${BINARIES[0]}" "$APP/Contents/MacOS/OverInk"
fi

cp Resources/Info.plist "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$APP/Contents/Info.plist"

./scripts/build-icon.sh
cp .build/OverInk.icns "$APP/Contents/Resources/OverInk.icns"

SIGNING_IDENTITY="${SIGNING_IDENTITY:--}"
if [[ "$SIGNING_IDENTITY" == '-' ]]; then
    codesign --force --sign - "$APP"
else
    codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$APP"
fi

codesign --verify --deep --strict "$APP"
plutil -lint "$APP/Contents/Info.plist"
echo "Built $APP ($VERSION)"
