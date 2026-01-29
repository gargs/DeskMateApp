#!/bin/bash
set -e

# Variables
APP_NAME="DeskMate"
APP_PATH="$1"
DMG_NAME="${APP_NAME}.dmg"
VOLUME_NAME="${APP_NAME}"
TEMP_DMG="temp.dmg"

# Validate input
if [ ! -d "$APP_PATH" ]; then
    echo "Usage: $0 <path-to-app>"
    echo "Example: $0 build/Build/Products/Release/DeskMate.app"
    exit 1
fi

# Clean up previous builds
rm -f "${DMG_NAME}" "${TEMP_DMG}"

# Create temporary directory for DMG contents
DMG_DIR=$(mktemp -d)
trap "rm -rf ${DMG_DIR}" EXIT

# Copy app to temp directory
cp -R "${APP_PATH}" "${DMG_DIR}/"

# Create Applications symlink
ln -s /Applications "${DMG_DIR}/Applications"

# Calculate size needed (app size + 50MB buffer)
SIZE=$(du -sm "${APP_PATH}" | awk '{print $1}')
SIZE=$((SIZE + 50))

# Create temporary DMG
hdiutil create -srcfolder "${DMG_DIR}" -volname "${VOLUME_NAME}" -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" -format UDRW -size ${SIZE}m "${TEMP_DMG}"

# Mount the temporary DMG
MOUNT_DIR=$(mktemp -d)
trap "rm -rf ${DMG_DIR} ${MOUNT_DIR}" EXIT
hdiutil attach "${TEMP_DMG}" -mountpoint "${MOUNT_DIR}" -nobrowse

# Configure Finder view settings (skip on CI/headless environments)
if [ -z "$CI" ]; then
    echo '
       tell application "Finder"
         tell disk "'${VOLUME_NAME}'"
               open
               set current view of container window to icon view
               set toolbar visible of container window to false
               set statusbar visible of container window to false
               set the bounds of container window to {400, 100, 1000, 500}
               set viewOptions to the icon view options of container window
               set arrangement of viewOptions to not arranged
               set icon size of viewOptions to 100
               set position of item "'${APP_NAME}'.app" of container window to {150, 200}
               set position of item "Applications" of container window to {450, 200}
               update without registering applications
               delay 2
         end tell
       end tell
    ' | osascript || echo "Warning: Could not configure Finder view (headless environment?)"
fi

# Sync and unmount
sync
sleep 2
hdiutil detach "${MOUNT_DIR}" -force || true

# Convert to compressed read-only DMG
hdiutil convert "${TEMP_DMG}" -format UDZO -imagekey zlib-level=9 -o "${DMG_NAME}"

# Clean up temp DMG
rm -f "${TEMP_DMG}"

echo "DMG created successfully: ${DMG_NAME}"
