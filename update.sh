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

# 3. Optionally Update Robot Model
DEFAULT_MODEL="mowbot-T1"
echo ""
if [ -f "$CONFIG_FILE" ]; then
    read -p "Robot config exists. Update model? (y/N): " UPDATE_CHOICE
    UPDATE_CHOICE=${UPDATE_CHOICE,,}
    if [[ "$UPDATE_CHOICE" == "y" ]]; then
        read -p "Enter robot model [mowbot-T1/mowbot-T2] (default: $DEFAULT_MODEL): " MODEL
        MODEL="${MODEL:-$DEFAULT_MODEL}"
        echo "robot_model: $MODEL" > "$CONFIG_FILE"
        echo "Robot model updated to '$MODEL' in $CONFIG_FILE."
    else
        MODEL=$(awk -F': ' '/robot_model:/ {print $2}' "$CONFIG_FILE")
        echo "Keeping existing robot model: $MODEL"
    fi
else
    echo "robot_model: $DEFAULT_MODEL" > "$CONFIG_FILE"
    echo "No config found. Defaulting to robot model: $DEFAULT_MODEL"
fi


echo
echo "Update complete!"
