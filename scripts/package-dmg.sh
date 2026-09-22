#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

VERSION="${VERSION:-$(cat VERSION)}"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo 'Invalid version' >&2; exit 1; }

APP="$PROJECT_ROOT/dist/OverInk.app"
[[ -d "$APP" ]] || { echo 'Run scripts/build-app.sh first.' >&2; exit 1; }

actual="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")"
[[ "$actual" == "$VERSION" ]] || { echo 'App version does not match VERSION.' >&2; exit 1; }

staging="$(mktemp -d "${TMPDIR:-/tmp}/overink-dmg.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
ditto "$APP" "$staging/OverInk.app"
ln -s /Applications "$staging/Applications"
cp LICENSE "$staging/License.txt"
printf 'Drag OverInk to Applications, then open it.\nUse Control-Option-D to start or stop drawing.\n' > "$staging/Read me.txt"

DMG="$PROJECT_ROOT/dist/OverInk-$VERSION.dmg"
hdiutil create -volname "OverInk $VERSION" -srcfolder "$staging" -ov -format UDZO "$DMG"
hdiutil verify "$DMG"

if [[ -n "${NOTARY_PROFILE:-}" ]]; then
    xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$DMG"
    xcrun stapler validate "$DMG"
fi

(cd dist && shasum -a 256 "OverInk-$VERSION.dmg" > "OverInk-$VERSION.dmg.sha256")
echo "Packaged $DMG"
