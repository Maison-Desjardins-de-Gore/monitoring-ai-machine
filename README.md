# AI Machine Monitoring System

## Overview
Monitoring script that runs in WSL parent environment (not in Docker containers).

## Files
- `monitor.sh` - Main monitoring script
- `config.env` - Configuration (add bot token)
- `20260411_0836.md` - Project documentation

## Installation
1. Add Telegram bot token to `config.env`
2. Make script executable: `chmod +x monitor.sh`
3. Install cron job: `*/10 * * * * /path/to/monitor.sh`

## Metrics
- GPU usage (%)
- VRAM usage (MB)
- Ollama processes & CPU
- CPU & RAM usage
- Docker containers (names only)

## Output
Concise Telegram messages every 10 minutes.
