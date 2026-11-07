#!/bin/bash
set -euo pipefail

ROOTLESS_DEB="${1:-$(ls -t packages/*_iphoneos-arm64.deb | head -1)}"
OUT_DEB="${2:-${ROOTLESS_DEB%_iphoneos-arm64.deb}_iphoneos-arm64e.deb}"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/copylogfix18-roothide.XXXXXX")"

cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

dpkg-deb -x "$ROOTLESS_DEB" "$WORK/root"
dpkg-deb -e "$ROOTLESS_DEB" "$WORK/DEBIAN"

if [ -d "$WORK/root/var/jb" ]; then
    shopt -s dotglob
    mv "$WORK/root/var/jb"/* "$WORK/root/"
    rm -rf "$WORK/root/var"
fi

# RootHide keeps native tweaks in Library/MobileSubstrate/DynamicLibraries
# and resolves substrate through the jbroot-relative loader path.
while IFS= read -r -d '' file; do
    if ! file "$file" | grep -q 'Mach-O'; then
        continue
    fi

    rel="${file#"$WORK/root"}"
    install_name_tool -id "$rel" "$file" 2>/dev/null || true

    install_name_tool -change "@rpath/CydiaSubstrate.framework/CydiaSubstrate" \
        "@loader_path/.jbroot/usr/lib/libsubstrate.dylib" "$file" 2>/dev/null || true

    for rpath in /var/jb/Library/Frameworks /var/jb/usr/lib \
                 "@loader_path/.jbroot/Library/Frameworks" "@loader_path/.jbroot/usr/lib"; do
        install_name_tool -delete_rpath "$rpath" "$file" 2>/dev/null || true
    done

    ldid -S "$file"
done < <(find "$WORK/root/Library/MobileSubstrate/DynamicLibraries" -type f -size +0c -print0 2>/dev/null)

sed -i '' 's/^Architecture: .*/Architecture: iphoneos-arm64e/' "$WORK/DEBIAN/control"
rm -rf "$WORK/root/DEBIAN"
cp -R "$WORK/DEBIAN" "$WORK/root/DEBIAN"
dpkg-deb -Zzstd --build --root-owner-group "$WORK/root" "$OUT_DEB"

echo "Built $OUT_DEB"
