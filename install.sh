#!/bin/bash
set -e

IMAGE_NAME="ghcr.io/serene4mr/mowbot_legacy:latest"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_SRC="$SCRIPT_DIR/mowbot_legacy_data"
DATA_DEST="$HOME_DIR/mowbot_legacy_data"
CONFIG_FILE="$DATA_DEST/robot_config.yaml"

# 1. Udev Rules
echo "Setting up udev rules..."
bash "$SCRIPT_DIR/udev/create_udev_rules.sh"

# 2. Pull Docker Image
echo "Pulling Docker image: $IMAGE_NAME"
docker pull "$IMAGE_NAME"

# 3. Copy/Update Data Directory
if [ -d "$DATA_DEST" ]; then
    echo "Syncing data directory..."
    rsync -a --delete "$DATA_SRC/" "$DATA_DEST/"
else
    echo "Copying data directory..."
    cp -r "$DATA_SRC" "$DATA_DEST"
fi

# 4. Robot Model Selection
DEFAULT_MODEL="mowbot-T1"
echo ""
if [ -f "$CONFIG_FILE" ]; then
    read -p "Robot config exists. Update model? (y/N): " UPDATE_CHOICE
    UPDATE_CHOICE=${UPDATE_CHOICE,,}
    if [[ "$UPDATE_CHOICE" == "y" ]]; then
        read -p "Enter robot model [mowbot-T1/mowbot-T2] (default: $DEFAULT_MODEL): " MODEL
        MODEL="${MODEL:-$DEFAULT_MODEL}"
        echo "robot_model: $MODEL" > "$CONFIG_FILE"
    else
        MODEL=$(awk -F': ' '/robot_model:/ {print $2}' "$CONFIG_FILE")
        echo "Keeping existing robot model: $MODEL"
    fi
else
    read -p "Enter robot model [mowbot-T1/mowbot-T2] (default: $DEFAULT_MODEL): " MODEL
    MODEL="${MODEL:-$DEFAULT_MODEL}"
    echo "robot_model: $MODEL" > "$CONFIG_FILE"
fi

echo ""
echo "Installation complete!"
echo "Robot model set to '$MODEL' in $CONFIG_FILE."
echo ""
