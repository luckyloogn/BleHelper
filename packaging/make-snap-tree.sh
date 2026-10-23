#!/usr/bin/env bash
#
# Assemble a snap tree from the unpacked AppImage payload, ready for "snapcraft pack".
#
# Usage: make-snap-tree.sh <appdir> <version> <snap-arch> <output-dir>
#   <appdir>      the unpacked AppImage payload (squashfs-root)
#   <version>     snap version without a leading "v", e.g. 1.1.1
#   <snap-arch>   amd64 or arm64
#   <output-dir>  the tree is written to <output-dir>/snap-tree
#
# The payload goes to the root of the snap, which is what the RPATH of the bundled binaries
# ($ORIGIN/../lib) and the qt.conf next to them expect. Building the tree here keeps the snap
# byte-identical to the AppImage and deb, and lets the snap be packed on a runner that has
# snapd (it cannot run inside the build container).
set -euo pipefail

if [ $# -ne 4 ]; then
  echo "usage: $0 <appdir> <version> <snap-arch> <output-dir>" >&2
  exit 2
fi

SRC=$(readlink -f "$1")
VERSION="$2"
ARCH="$3"
OUTDIR="$4"

TREE="$OUTDIR/snap-tree"
rm -rf "$TREE"
mkdir -p "$TREE/meta/gui"

# Payload, without the AppImage runtime bits
cp -a "$SRC"/. "$TREE"/
rm -f "$TREE/AppRun" "$TREE/.DirIcon" "$TREE"/*.desktop "$TREE"/*.svg

# Launcher used by the snap (and by the desktop entry)
mkdir -p "$TREE/usr/bin"
cat > "$TREE/usr/bin/blehelper" <<'EOF'
#!/bin/sh
exec "$SNAP/usr/bin/BleHelper" "$@"
EOF
chmod 0755 "$TREE/usr/bin/blehelper"

cat > "$TREE/usr/share/applications/blehelper.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=BLE Helper
Comment=Bluetooth Low Energy debugging assistant
Exec=blehelper
Icon=${SNAP}/meta/gui/blehelper.svg
Terminal=false
Categories=Utility;Development;
Keywords=BLE;Bluetooth;
EOF

ICON=$(find "$TREE" -name '*.svg' -print -quit 2>/dev/null || true)
if [ -n "$ICON" ] && [ "$ICON" != "$TREE/meta/gui/blehelper.svg" ]; then
  cp "$ICON" "$TREE/meta/gui/blehelper.svg"
fi
cp "$TREE/usr/share/applications/blehelper.desktop" "$TREE/meta/gui/blehelper.desktop"

cat > "$TREE/meta/snap.yaml" <<EOF
name: blehelper
title: BLE Helper
version: '$VERSION'
summary: Bluetooth Low Energy debugging assistant
description: |
  A desktop tool to scan for, connect to and debug BLE peripherals.
  The Qt libraries it needs are bundled inside the snap.
base: core22
grade: stable
# The app talks to BlueZ over the system bus and needs the raw HCI sockets, which strict
# confinement only grants through a handful of interfaces; classic keeps it usable.
confinement: classic
architectures:
  - $ARCH
apps:
  blehelper:
    command: usr/bin/blehelper
    desktop: usr/share/applications/blehelper.desktop
EOF

echo "Prepared $TREE"
