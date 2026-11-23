#!/bin/bash
set -euo pipefail
if [[ $# != 3 ]]; then
  echo "Usage: bash $0 /absolute/Processing.app /absolute/source-root /absolute/output.dmg" >&2
  exit 2
fi
processing=$1/Contents
source_root=$2
output=$3
work=$(mktemp -d "${TMPDIR:-/tmp}/openbci-export.XXXXXX")
trap 'rm -rf -- "$work"' EXIT
java=$(find "$processing/PlugIns" -path '*/bin/java' -type f -print -quit)
test -x "$java"
mkdir -p "$work/home/Library/Processing" "$work/image" "$(dirname "$output")"
ditto "$source_root/OpenBCI_GUI" "$work/sketchbook/OpenBCI_GUI"
ditto "$source_root/OpenBCI_GUI/libraries" "$work/sketchbook/libraries"
printf 'sketchbook.path.four=%s/sketchbook\n' "$work" > "$work/home/Library/Processing/preferences.txt"
(
  cd "$processing/Java"
  "$java" -Duser.home="$work/home" -Djna.nosys=true -cp '*:core/library/*:modes/java/mode/*' \
    processing.mode.java.Commander --sketch="$work/sketchbook/OpenBCI_GUI" \
    --output="$work/export" --variant=macos-aarch64 --export
)
app="$work/export/OpenBCI_GUI.app"
test "$(lipo -archs "$app/Contents/MacOS/OpenBCI_GUI")" = arm64
cp "$source_root/OpenBCI_GUI/sketch.icns" "$app/Contents/Resources/sketch.icns"
codesign --force --sign - "$app"
codesign --verify --deep --strict "$app"
ditto "$app" "$work/image/OpenBCI_GUI.app"
ln -s /Applications "$work/image/Applications"
cp "$source_root/LICENSE" "$work/image/LICENSE.txt"
hdiutil create -srcfolder "$work/image" -volname 'OpenBCI GUI' -fs HFS+ -format UDZO "$output"
hdiutil verify "$output"
