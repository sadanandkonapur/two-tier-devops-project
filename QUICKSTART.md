# Quick Start Guide

## Installation Steps

### Windows
1. **Install Docker Desktop:**
   - Download: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe
   - Run the installer and follow prompts
   - **Restart your computer**

2. **Run the setup script:**
   ```powershell
   cd C:\two-tier-devops-project
   .\setup.bat
   ```

### Linux/Mac
1. **Install Docker:**
   - Visit: https://www.docker.com/products/docker-desktop

2. **Run the setup script:**
   ```bash
   cd two-tier-devops-project
   chmod +x setup.sh
   ./setup.sh
   ```

## Manual Start (if setup script fails)

```bash
cd C:\two-tier-devops-project
docker compose up -d
```

## Access Application
- **Web UI:** http://localhost:5000
- **API Health:** http://localhost:5000/health

## Troubleshooting

### Docker not found
- Ensure Docker Desktop is installed and running
- Restart your terminal/PowerShell after installation

### Containers not starting
```bash
# Check logs
docker compose logs

# Restart services
docker compose restart
```

### MySQL connection failed
- Wait 30 seconds for MySQL to fully initialize
- Check: `docker compose ps`

## Stop the Application
```bash
docker compose down
```

## View Logs
```bash
docker compose logs -f
```
