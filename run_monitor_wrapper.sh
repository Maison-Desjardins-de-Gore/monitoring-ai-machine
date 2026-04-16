#!/bin/bash
# Wrapper to load the secure token before running monitor.sh

# Use the directory where the script is located
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Load the configuration from config.env
if [ -f "$PROJECT_DIR/config.env" ]; then
    source "$PROJECT_DIR/config.env"
else
    echo "❌ Error: config.env not found in $PROJECT_DIR"
    exit 1
fi

# 2. Load the token from the secure path defined in config.env
if [ -n "$BOT_TOKEN_FILE_PATH" ] && [ -f "$BOT_TOKEN_FILE_PATH" ]; then
    export TELEGRAM_BOT_TOKEN=$(cat "$BOT_TOKEN_FILE_PATH")
    echo "✅ Token loaded from $BOT_TOKEN_FILE_PATH"
else
    echo "❌ Error: Token file not found at $BOT_TOKEN_FILE_PATH"
    exit 1
fi

# 3. Run the actual monitor script
bash "$PROJECT_DIR/monitor.sh"
