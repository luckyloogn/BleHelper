#!/usr/bin/env bash
#
# Build a .deb from the tree the AppImage ships with.
#
# Usage: make-deb.sh <appdir> <version> <deb-arch> <output-dir>
#   <appdir>      the unpacked AppImage payload (squashfs-root)
#   <version>     package version without a leading "v", e.g. 1.1.1
#   <deb-arch>    amd64 or arm64
#   <output-dir>  where the .deb is written
#
# The payload goes to /opt/blehelper and a small launcher is put into /usr/bin, so that the
# bundled libraries cannot clash with the ones of the system. Qt stays as separate shared
# libraries, which is what LGPLv3 expects: they can be replaced by the user.
set -euo pipefail

if [ $# -ne 4 ]; then
  echo "usage: $0 <appdir> <version> <deb-arch> <output-dir>" >&2
  exit 2
fi

SRC=$(readlink -f "$1")
VERSION="$2"
ARCH="$3"
OUTDIR="$4"

APP=BleHelper
PKG=blehelper
PREFIX=/opt/blehelper

# A version has to start with a digit; branch builds get something like "dev-37".
case "$VERSION" in
  [0-9]*) ;;
  *) VERSION="0~$VERSION" ;;
esac

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
ROOT="$WORK/$PKG"

mkdir -p "$ROOT$PREFIX" \
         "$ROOT/usr/bin" \
         "$ROOT/usr/share/applications" \
         "$ROOT/usr/share/doc/$PKG" \
         "$ROOT/DEBIAN"

# The payload, without the AppImage runtime bits, which mean nothing outside of an AppImage
for entry in "$SRC"/*; do
  case "$(basename "$entry")" in
    AppRun|*.desktop|*.svg|*.png) continue ;;
  esac
  cp -a "$entry" "$ROOT$PREFIX/"
done

# Launcher
cat > "$ROOT/usr/bin/$PKG" <<EOF
#!/bin/sh
exec $PREFIX/usr/bin/$APP "\$@"
EOF
chmod 0755 "$ROOT/usr/bin/$PKG"

# Icon (the AppDir ships an SVG)
ICON=$(find "$SRC" -name '*.svg' -print -quit 2>/dev/null || true)
if [ -z "$ICON" ]; then
  ICON=$(find "$SRC" -name '*.png' -print -quit 2>/dev/null || true)
  ICON_DIR="$ROOT/usr/share/icons/hicolor/256x256/apps"
else
  ICON_DIR="$ROOT/usr/share/icons/hicolor/scalable/apps"
fi
if [ -n "$ICON" ]; then
  mkdir -p "$ICON_DIR"
  cp "$ICON" "$ICON_DIR/$PKG.${ICON##*.}"
fi

cat > "$ROOT/usr/share/applications/$PKG.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=BLE Helper
Comment=Bluetooth Low Energy debugging assistant
Exec=$PKG
Icon=$PKG
Terminal=false
Categories=Utility;Development;
Keywords=BLE;Bluetooth;
EOF

# License texts: ours, plus the notice about the Qt libraries that are shipped along
REPO=$(dirname "$0")/..
cp "$REPO/LICENSE" "$ROOT/usr/share/doc/$PKG/LICENSE"
if [ -f "$REPO/THIRD_PARTY_NOTICES.md" ]; then
  cp "$REPO/THIRD_PARTY_NOTICES.md" "$ROOT/usr/share/doc/$PKG/"
fi
if [ -d "$REPO/LICENSES" ]; then
  cp -r "$REPO/LICENSES" "$ROOT/usr/share/doc/$PKG/"
fi

cat > "$ROOT/usr/share/doc/$PKG/copyright" <<EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: BleHelper
Source: https://github.com/luckyloogn/BleHelper

Files: *
Copyright: 2024 luckyloogn
License: MIT
 See LICENSE in this directory.

Files: $PREFIX/usr/lib/libQt6*.so*
Copyright: The Qt Company Ltd. and contributors
License: LGPL-3.0-only
 Qt is bundled unmodified as separate shared libraries, so it can be replaced by the user.
 The source is available from https://download.qt.io/official_releases/qt/6.8/6.8.1/
EOF

INSTALLED_SIZE=$(du -sk "$ROOT" | cut -f1)
cat > "$ROOT/DEBIAN/control" <<EOF
Package: $PKG
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: luckyloogn <luckyloogn@users.noreply.github.com>
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.34), libstdc++6, libgcc-s1, libglib2.0-0, libdbus-1-3, libfontconfig1, libfreetype6, libgl1, libegl1, libx11-6, libx11-xcb1, libxkbcommon-x11-0, libxcb1, libxcb-cursor0, libxcb-icccm4, libxcb-image0, libxcb-keysyms1, libxcb-randr0, libxcb-render-util0, libxcb-shape0, libxcb-shm0, libxcb-sync1, libxcb-xfixes0, libxcb-xinerama0, libxcb-xkb1
Homepage: https://github.com/luckyloogn/BleHelper
Description: Bluetooth Low Energy debugging assistant
 A desktop tool to scan for, connect to and debug BLE peripherals.
 .
 The Qt libraries it needs are bundled in $PREFIX.
EOF

mkdir -p "$OUTDIR"
dpkg-deb --root-owner-group --build "$ROOT" "$OUTDIR/${PKG}_${VERSION}_${ARCH}.deb"
echo "Built $OUTDIR/${PKG}_${VERSION}_${ARCH}.deb"
