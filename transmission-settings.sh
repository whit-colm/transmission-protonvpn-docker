#!/bin/bash
# Transmission settings customization
# This runs before Transmission starts to configure download directories

SETTINGS_FILE="/config/settings.json"

# Wait for settings.json to be created by the container init
while [ ! -f "$SETTINGS_FILE" ]; do
    sleep 1
done

# Stop transmission if it's running (shouldn't be at this point, but safety first)
pkill transmission-daemon 2>/dev/null
sleep 1

# Modify settings to use single download directory
sed -i \
    -e 's|"download-dir": "/downloads/complete"|"download-dir": "/downloads"|' \
    -e 's|"incomplete-dir-enabled": true|"incomplete-dir-enabled": false|' \
    "$SETTINGS_FILE"

echo "Transmission settings configured: single download directory at /downloads"
