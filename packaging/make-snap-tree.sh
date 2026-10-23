#!/usr/bin/env bash
#
# Assemble a snap tree from the unpacked AppImage payload, ready for "snap pack".
#
# Usage: make-snap-tree.sh <appdir> <version> <snap-arch> <output-dir>
#   <appdir>      the unpacked AppImage payload (squashfs-root)
#   <version>     snap version without a leading "v", e.g. 1.1.1
#   <snap-arch>   amd64 or arm64
#   <output-dir>  the tree is written to <output-dir>/snap-tree
#
# Environment:
#   SNAP_BASE     base snap the package is built against (default core22)
#
# The payload goes to the root of the snap, which is what the RPATH of the bundled binaries
# ($ORIGIN/../lib) and the qt.conf next to them expect. Building the tree here keeps the snap
# byte-identical to the AppImage and deb.
set -euo pipefail

if [ $# -ne 4 ]; then
  echo "usage: $0 <appdir> <version> <snap-arch> <output-dir>" >&2
  exit 2
fi

SRC=$(readlink -f "$1")
VERSION="$2"
ARCH="$3"
OUTDIR="$4"
BASE=${SNAP_BASE:-core22}

TREE="$OUTDIR/snap-tree"
rm -rf "$TREE"
mkdir -p "$TREE/meta/gui"

# Payload, without the AppImage runtime bits
cp -a "$SRC"/. "$TREE"/
rm -f "$TREE/AppRun" "$TREE/.DirIcon" "$TREE"/*.desktop "$TREE"/*.svg

# The desktop file of the AppDir points at the executable by its bare name, which does not work
# inside a snap, so it is replaced by one that uses the command declared in snap.yaml.
rm -f "$TREE"/usr/share/applications/*.desktop
mkdir -p "$TREE/usr/share/applications"

# Launcher: $SNAP is where snapd mounts the package
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
cp "$TREE/usr/share/applications/blehelper.desktop" "$TREE/meta/gui/blehelper.desktop"

ICON=$(find "$TREE" -name '*.svg' -print -quit 2>/dev/null || true)
if [ -n "$ICON" ]; then
  cp "$ICON" "$TREE/meta/gui/blehelper.svg"
fi

cat > "$TREE/meta/snap.yaml" <<EOF
name: blehelper
title: BLE Helper
version: '$VERSION'
summary: Bluetooth Low Energy debugging assistant
description: |
  A desktop tool to scan for, connect to and debug BLE peripherals.
  The Qt libraries it needs are bundled inside the snap.
base: $BASE
grade: stable
# The app talks to BlueZ over the system bus and opens raw HCI sockets, which strict
# confinement only grants through a handful of interfaces that need manual connection.
confinement: classic
license: MIT
architectures:
  - $ARCH
apps:
  blehelper:
    command: usr/bin/blehelper
    desktop: usr/share/applications/blehelper.desktop
EOF

echo "Prepared $TREE (base $BASE, $ARCH, version $VERSION)"
