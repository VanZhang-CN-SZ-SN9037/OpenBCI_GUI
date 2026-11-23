#!/bin/bash
set -uo pipefail
dmg=${1:?usage: launch-smoke.sh /absolute/app.dmg /absolute/launch-smoke.log}
log=${2:?usage: launch-smoke.sh /absolute/app.dmg /absolute/launch-smoke.log}
work=$(mktemp -d "${TMPDIR:-/tmp}/openbci-smoke.XXXXXX")
trap 'rm -rf -- "$work"' EXIT
mount_point=$(hdiutil attach -readonly -nobrowse "$dmg" 2>/dev/null | awk -F'\t' '/\/Volumes\// {print $NF}' | tail -1)
if [[ -z "$mount_point" ]]; then
  echo "failed to mount $dmg" >&2
  exit 1
fi
source_app="$mount_point/OpenBCI_GUI.app"
lipo -archs "$source_app/Contents/MacOS/OpenBCI_GUI"
codesign --verify --deep --strict "$source_app"
ditto "$source_app" "$work/OpenBCI_GUI.app"
hdiutil detach "$mount_point" -force >/dev/null 2>&1 || true
mkdir -p "$work/home/Documents"
JAVA_TOOL_OPTIONS="-Duser.home=$work/home" "$work/OpenBCI_GUI.app/Contents/MacOS/OpenBCI_GUI" > "$work/stdout.log" 2>&1 &
app_pid=$!
sleep 35
kill -TERM "$app_pid" 2>/dev/null || true
for _ in $(seq 1 20); do
  kill -0 "$app_pid" 2>/dev/null || break
  sleep 1
done
kill -KILL "$app_pid" 2>/dev/null || true
wait "$app_pid" 2>/dev/null || true
newest=$(ls -t "$work/home/Documents/OpenBCI_GUI/Console_Data/"Console_*.txt 2>/dev/null | head -1)
if [[ -z "$newest" ]]; then
  echo "no console log created" >&2
  cat "$work/stdout.log" >&2
  exit 1
fi
cp "$newest" "$log"
