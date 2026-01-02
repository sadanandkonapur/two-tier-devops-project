#!/bin/bash
# Two-Tier DevOps Project Setup Script (Linux/Mac)

echo ""
echo "========================================"
echo "Two-Tier DevOps Project Setup"
echo "========================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker is not installed!"
    echo ""
    echo "Please install Docker from: https://www.docker.com/products/docker-desktop"
    echo ""
    exit 1
fi

echo "[OK] Docker found:"
docker --version
echo ""

# Check if Docker daemon is running
if ! docker ps &> /dev/null; then
    echo "[ERROR] Docker daemon is not running!"
    echo ""
    echo "Please start Docker and try again."
    echo ""
    exit 1
fi

echo "[OK] Docker daemon is running"
echo ""

# Start the application
echo "[INFO] Starting the two-tier application..."
echo ""

cd "$(dirname "$0")"

docker compose down -q
sleep 2

docker compose up -d

echo ""
echo "========================================"
echo "Application Starting..."
echo "========================================"
echo ""
echo "Web Application:   http://localhost:5000"
echo "MySQL Database:    localhost:3306"
echo ""
echo "Containers status:"
docker compose ps
echo ""
echo "[INFO] Wait 30 seconds for MySQL to initialize..."
echo "[INFO] Then access http://localhost:5000 in your browser"
echo ""
echo "To view logs, run: docker compose logs -f"
echo "To stop, run: docker compose down"
echo ""
