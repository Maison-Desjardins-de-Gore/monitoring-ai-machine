#!/bin/bash

# AI Machine Monitoring Script (Phase 2: Error Detection)
# Runs in WSL parent environment, not in Docker containers
# Sends concise Telegram updates every 10 minutes

# Configuration (Loaded from config.env via wrapper)
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:--1003796017691}"
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-YOUR_BOT_TOKEN_HERE}"

# Target Containers
CONTAINERS=("openclaw" "ollama")

# Get current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Initialize message
MSG="🖥️ *AI Machine Status - $TIMESTAMP*\n\n"

# --- 1. Hardware Usage ---

# GPU Usage (nvidia-smi)
GPU_USAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
if [ -n "$GPU_USAGE" ]; then
    MSG+="🎮 GPU: ${GPU_USAGE}%\n"
else
    MSG+="🎮 GPU: N/A\n"
fi

# VRAM Usage (nvidia-smi)
VRAM_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
VRAM_USED=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -1)
if [ -n "$VRAM_USED" ] && [ -n "$VRAM_TOTAL" ]; then
    MSG+="💾 VRAM: ${VRAM_USED}/${VRAM_TOTAL} MB\n"
else
    MSG+="💾 VRAM: N/A\n"
fi

# CPU and RAM Usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "N/A")
if [ "$CPU_USAGE" = "N/A" ] || [ -z "$CPU_USAGE" ]; then
    CPU_USAGE=$(grep 'cpu_usage' /sys/fs/cgroup/cpu/cpu.usage 2>/dev/null || echo "N/A")
fi
MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/^Mem:/ {print $3}')
if [ -n "$MEM_TOTAL" ] && [ "$MEM_TOTAL" -gt 0 ]; then
    MEM_PCT=$((MEM_USED * 100 / MEM_TOTAL))
    MSG+="💻 CPU: $CPU_USAGE | RAM: ${MEM_PCT}% ($MEM_USED/$MEM_TOTAL MB)\n"
else
    MSG+="💻 CPU: $CPU_USAGE | RAM: N/A\n"
fi

# --- 2. Docker Services & Error Detection ---

MSG+="\n🐳 *Services:*\n"
ERROR_FOUND=false
ERROR_LOGS=""

for container in "${CONTAINERS[@]}"; do
    # Check if container is running
    if [ "$(docker inspect -f '{{.State.Running}}' $container 2>/dev/docker_check_err 2>/dev/null)" = "true" ]; then
        MSG+="✅ $container: Running\n"
        
        # Check for recent errors in logs (last 10 mins)
        # We look for common error patterns
        ERR_LINE=$(docker logs --since 10m $container 2>/dev/null | grep -Ei "error|fail|critical|exception|panic|unauthorized|refused" | tail -n 1)
        
        if [ -n "$ERR_LINE" ]; then
            ERROR_FOUND=true
            # Clean up the error line for Telegram (remove newlines/excessive length)
            CLEAN_ERR=$(echo "$ERR_LINE" | sed 's/[[:space:]]\+/ /g' | cut -c 1-100)
            ERROR_LOGS+="⚠️ [$container] $CLEAN_ERR\n"
        fi
    else
        MSG+="❌ $container: **STOPPED**\n"
        ERROR_FOUND=true
        ERROR_LOGS+="❌ [$container] Container is not running!\n"
    fi
done

# Append errors to the main message if any were found
if [ "$ERROR_FOUND" = true ]; then
    MSG+="\n🚨 *Recent Errors:*\n$ERROR_LOGS"
fi

# --- 3. Send to Telegram ---

if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ "$TELEGRAM_BOT_TOKEN" != "YOUR_BOT_TOKEN_HERE" ]; then
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
      -d "chat_id=${TELEGRAM_CHAT_ID}&text=${MSG}&parse_mode=Markdown" > /dev/null
else
    echo "⚠️ Telegram Bot Token not configured. Skipping notification."
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Monitoring check completed"
