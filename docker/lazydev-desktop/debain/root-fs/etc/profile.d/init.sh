#!/bin/bash

# Only execute in WSL environment
if grep -q "microsoft" /proc/version &>/dev/null; then

    # Configuration variables - modify these according to your setup!
    SOURCE_DISTRO="lazydev-desktop-data"    # Source WSL instance name (check with `wsl -l -v`)
    MOUNT_POINT="/mnt/wsl/$SOURCE_DISTRO" # Mount point path

    # Check if already mounted, skip if true
    if ! mountpoint -q "$MOUNT_POINT"; then
        echo "Attempting to mount $SOURCE_DISTRO filesystem..."

        # Ensure mount point directory exists
        mkdir -p "$MOUNT_POINT" 2>/dev/null || true

        # Check if source instance is running, start it if not
        if ! wsl.exe -d "$SOURCE_DISTRO" -e true 2>/dev/null; then
            echo "Starting WSL instance: $SOURCE_DISTRO..."
            # Start instance without attaching terminal (run in background)
            nohup wsl.exe -d "$SOURCE_DISTRO" -- &>/dev/null &
            # Wait for instance to start
            sleep 1
        fi

        # Attempt to mount (retry up to 3 times with 1-second intervals)
        for attempt in 1 2 3; do
            echo $attempt
            if wsl.exe -d "$SOURCE_DISTRO" -u root mount --bind /data/ "$MOUNT_POINT" 2>/dev/null; then
                echo "Successfully mounted $SOURCE_DISTRO to: $MOUNT_POINT"
                break
            else
                if [ $attempt -eq 3 ]; then
                    echo "Error: Failed to mount $SOURCE_DISTRO (attempted $attempt times)"
                else
                    echo "Mount attempt $attempt failed, retrying..."
                    sleep 1
                fi
            fi
        done
    fi
fi
