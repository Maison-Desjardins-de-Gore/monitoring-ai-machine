#!/bin/bash

# AI Machine Monitoring Script
# Runs in WSL parent environment, not in Docker containers
# Sends concise Telegram updates every 10 minutes

TELEGRAM_CHAT_ID="-1003796017691"
TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN_HERE"

# Get current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Initialize message
MSG="🖥️ *AI Machine Status - $TIMESTAMP*\n\n"

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

# GPU/CPU Ratio (Ollama)
OLLAMA_PS=$(ollama ps 2>/dev/null | tail -n +2)
if [ -n "$OLLAMA_PS" ]; then
    OLLAMA_COUNT=$(echo "$OLLAMA_PS" | wc -l)
    OLLAMA_CPU=$(echo "$OLLAMA_PS" | awk '{sum+=$3; count++} END {if(count>0) print sum/count; else print 0}')
    MSG+="🤖 Ollama: $OLLAMA_COUNT process(es), CPU: ${OLLAMA_CPU}%\n"
else
    MSG+="🤖 Ollama: No active processes\n"
fi

# CPU and RAM Usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "N/A")
if [ "$CPU_USAGE" = "N/A" ] || [ -z "$CPU_USAGE" ]; then
    CPU_USAGE=$(grep 'cpu_usage' /sys/fs/cgroup/cpu/cpu.usage 2>/dev/null || echo "N/A")
fi
MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/^Mem:/ {print $3}')
if [ "$MEM_TOTAL" != "N/A" ] && [ "$MEM_TOTAL" -gt 0 ]; then
    MEM_PCT=$((MEM_USED * 100 / MEM_TOTAL))
    MEM_USAGE="${MEM_PCT}% ($MEM_USED/$MEM_TOTAL MB)"
else
    MEM_USAGE="N/A"
fi
MSG+="💻 CPU: $CPU_USAGE | RAM: $MEM_USAGE\n"

# Running Docker Containers
DOCKER_CONTAINERS=$(docker ps --format "{{.Names}}" 2>/dev/null)
if [ -n "$DOCKER_CONTAINERS" ]; then
    MSG+="🐳 Containers: $(echo "$DOCKER_CONTAINERS" | tr '\n' ' ' | sed 's/ $//')\n"
else
    MSG+="🐳 Containers: None running\n"
fi

# Send to Telegram
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d "chat_id=${TELEGRAM_CHAT_ID}&text=${MSG}&parse_mode=Markdown" > /dev/null

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Monitoring check completed"
