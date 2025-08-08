#!/bin/bash
set -e

IMAGE_NAME="ghcr.io/serene4mr/mowbot_legacy:latest"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_SRC="$SCRIPT_DIR/mowbot_legacy_data"
DATA_DEST="$HOME_DIR/mowbot_legacy_data"
CONFIG_FILE="$DATA_DEST/robot_config.yaml"

# 1. Pull latest Docker image
echo "Pulling latest Docker image: $IMAGE_NAME"
docker pull "$IMAGE_NAME"

if [ -d "$DATA_DEST" ]; then
    echo "Adding new files to data directory only; existing files untouched."
    rsync -a --ignore-existing "$DATA_SRC/" "$DATA_DEST/"
else
    echo "Copying new data directory..."
    cp -r "$DATA_SRC" "$DATA_DEST"
fi


echo
echo "Update complete!"
