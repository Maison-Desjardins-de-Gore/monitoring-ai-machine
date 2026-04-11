# Monitoring AI Machine Project

## Overview
Monitoring system for AI machine that runs in WSL parent environment (not in Docker containers).

## Repository
- URL: `https://github.com/Maison-Desjardins-de-Gore/monitoring-ai-machine`
- Branch: `main`

## Features
- GPU usage monitoring (nvidia-smi)
- VRAM usage monitoring
- Ollama process tracking
- CPU/RAM usage
- Docker container status
- Telegram notifications every 10 minutes

## Configuration
- Telegram chat ID: `-1003796017691`
- Cron job: `*/10 * * * *`
- Script location: `/home/node/.openclaw/workspace/monitoring-ai-machine/monitor.sh`

## Installation Status
- Script created: ✅
- Git repo initialized: ✅
- GitHub repo: Needs manual creation
- Cron job: Pending installation
- Bot token: Pending configuration

## Next Steps
1. Create GitHub repository manually
2. Push code to GitHub
3. Configure bot token in `config.env`
4. Install cron job
5. Test monitoring
