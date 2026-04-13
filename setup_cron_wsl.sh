#!/bin/bash
# Setup script for monitoring-ai-machine cron job
# This script should be run by the user 'andy' in the WSL parent environment.

# Use the directory where the script is located to avoid absolute path issues
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER_SCRIPT="$PROJECT_DIR/run_monitor_wrapper.sh"
CRON_CMD="*/10 * * * * $WRAPPER_SCRIPT"

echo "🚀 Starting setup for monitoring-ai-machine cron job..."

# 1. Create the wrapper script that loads the token from the secure path
echo "📝 Creating wrapper script: $WRAPPER_SCRIPT"
cat << 'WRAPPER_EOF' > "$WRAPPER_SCRIPT"
#!/bin/bash
# Wrapper to load the secure token before running monitor.sh

# Use the directory where the script is located
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load the config from config.env
if [ -f "$PROJECT_DIR/config.env" ]; then
    source "$PROJECT_DIR/config.env"
else
    echo "❌ Error: config.env not found in $PROJECT_DIR"
    exit 1
fi

# Load the token from the secure path
if [ -n "$BOT_TOKEN_FILE_PATH" ] && [ -f "$BOT_TOKEN_FILE_PATH" ]; then
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

# 2. Output the cron command for the user to add manually
echo ""
echo "✅ Wrapper script created and made executable."
echo ""
echo "👉 To install the cron job in your WSL parent environment, run:"
echo "   (crontab -l 2>/dev/null; echo \"$CRON_CMD\") | crontab -"
echo ""
echo "⚠️  Make sure the path in $WRAPPER_SCRIPT is correct for your WSL environment."
