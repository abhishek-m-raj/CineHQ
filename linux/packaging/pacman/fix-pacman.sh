#!/bin/bash

# Find the newly generated broken .pacman file
PACMAN_FILE=$(find dist -name "*.pacman" | head -n 1)

if [ -z "$PACMAN_FILE" ]; then
  echo "❌ No .pacman file found to fix!"
  exit 0
fi

echo "🛠️ Applying final Arch patch to: $PACMAN_FILE"

# 1. Extract into temporary directory
rm -rf pacman-fix
mkdir -p pacman-fix
tar -xf "$PACMAN_FILE" -C pacman-fix

# Delete the original broken file immediately so we can reuse the name
rm "$PACMAN_FILE"

# 2. Dynamically re-format the broken .PKGINFO 
cd pacman-fix
> .PKGINFO_NEW

while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" ]] && continue
    
    # Split key and value, then trim whitespace
    key=$(echo "${line%%=*}" | xargs)
    val=$(echo "${line#*=}" | xargs)
    
    # Strip illegal Bash parentheses
    val="${val#(}"
    val="${val%)}"

    # FIX: Force pkgver to have a release number (e.g., 0.11.0-1)
    if [[ "$key" == "pkgver" ]]; then
        if [[ "$val" != *-* ]]; then
            val="${val}-1"
        fi
        echo "pkgver = $val" >> .PKGINFO_NEW
    # FIX: Add pkgbase (highly recommended for Arch)
    elif [[ "$key" == "pkgname" ]]; then
        echo "pkgname = $val" >> .PKGINFO_NEW
        echo "pkgbase = $val" >> .PKGINFO_NEW
    elif [[ "$key" == "groups" ]]; then
        echo "group = $val" >> .PKGINFO_NEW
    elif [[ "$key" == "depends" ]]; then
        # Split commas and create multiple 'depend' lines
        IFS=',' read -ra DEPARRAY <<< "$val"
        for dep in "${DEPARRAY[@]}"; do
            clean_dep=$(echo "$dep" | xargs)
            echo "depend = $clean_dep" >> .PKGINFO_NEW
        done
    else
        echo "$key = $val" >> .PKGINFO_NEW
    fi
done < .PKGINFO

# Add mandatory size calculation
INSTALLED_SIZE=$(du -sb . | cut -f1)
echo "size = $INSTALLED_SIZE" >> .PKGINFO_NEW
mv .PKGINFO_NEW .PKGINFO

# 3. Zip it back up using the original .pacman extension
BASENAME=$(basename "$PACMAN_FILE")
DIST_DIR=$(cd .. && realpath "$(dirname "$PACMAN_FILE")")
NEW_FILE="${DIST_DIR}/${BASENAME}"

# Build the file list based on what actually exists
FILES_TO_PACK=".PKGINFO"
[ -f ".MTREE" ] && FILES_TO_PACK="$FILES_TO_PACK .MTREE"
[ -f ".INSTALL" ] && FILES_TO_PACK="$FILES_TO_PACK .INSTALL"
[ -d "usr" ] && FILES_TO_PACK="$FILES_TO_PACK usr"
[ -d "opt" ] && FILES_TO_PACK="$FILES_TO_PACK opt"

# We use Zstd compression even though the extension is .pacman
tar -c --zstd -f "$NEW_FILE" $FILES_TO_PACK

# 4. Show the user the metadata for verification
echo -e "\n--- GENERATED METADATA PREVIEW ---"
grep -E "pkgname|pkgver|depend" .PKGINFO
echo -e "----------------------------------\n"

cd ..
rm -rf pacman-fix

echo "✅ Success! CineHQ is ready for Pacman."
echo "Install with: sudo pacman -U ${DIST_DIR}/${BASENAME}"