#!/bin/bash

# Setup script for monitoring-ai-machine cron job
# This script should be run by the user 'andy'

PROJECT_DIR="/home/node/ai-projects/monitoring-ai-machine"
WRAPPER_SCRIPT="$PROJECT_DIR/run_monitor_wrapper.sh"
CRON_CMD="*/10 * * * * $WRAPPER_SCRIPT"

echo "🚀 Starting setup for monitoring-ai-machine..."

# 1. Create the wrapper script that loads the token from the secure path
echo "📝 Creating wrapper script: $WRAPPER_SCRIPT"
cat << 'WRAPPER_EOF' > "$WRAPPER_SCRIPT"
#!/bin/bash
# Wrapper to load the secure token before running monitor.sh

# Load the path from bot_token.env
if [ -f "$PROJECT_DIR/bot_token.env" ]; then
    source "$PROJECT_DIR/bot_token.env"
else
    echo "❌ Error: bot_token.env not found in $PROJECT_DIR"
    exit 1
fi

# Load the token from the secure path
if [ -f "$BOT_TOKEN_FILE_PATH" ]; then
    export TELEGRAM_BOT_TOKEN=$(cat "$BOT_TOKEN_FILE_PATH")
    echo "✅ Token loaded from $BOT_TOKEN_FILE_PATH"
else
    echo "❌ Error: Token file not found at $BOT_TOKEN_FILE_PATH"
    exit 1
fi

# Run the actual monitor script
bash "$PROJECT_DIR/monitor.sh"
WRAPPER_EOF

chmod +x "$WRAPPER_SCRIPT"

# 2. Install the cron job
echo "📅 Installing cron job: $CRON_CMD"
(crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -

echo "✅ Setup complete! The monitoring script is now scheduled to run every 10 minutes."
echo "👉 Make sure you have created '$PROJECT_DIR/bot_token.env' with the correct path to your secret token."
