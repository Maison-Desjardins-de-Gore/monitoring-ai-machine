#!/bin/bash
# Wrapper to load the secure token before running monitor.sh

# Use the directory where the script is located
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load the token from the secure path defined in config.env
if [ -f "$BOT_TOKEN_FILE_PATH" ]; then
    export TELEGRAM_BOT_TOKEN=$(cat "$BOT_TOKEN_FILE_PATH")
    echo "✅ Token loaded from $BOT_TOKEN_FILE_PATH"
else
    echo "❌ Error: Token file not found at $BOT_TOKEN_FILE_PATH"
    exit 1
fi

# Run the actual monitor script
bash "$PROJECT_DIR/monitor.sh"
