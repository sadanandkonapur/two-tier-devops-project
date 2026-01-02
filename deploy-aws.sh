#!/bin/bash
# AWS EC2 Deployment Script for Two-Tier DevOps Project
# Run this script on your fresh EC2 instance

set -e

echo "================================================"
echo "Two-Tier DevOps Project - AWS Deployment"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running on Ubuntu/Debian or Amazon Linux
if [ -f /etc/debian_version ]; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
    UPDATE_CMD="sudo apt update && sudo apt upgrade -y"
elif [ -f /etc/redhat-release ]; then
    PKG_MANAGER="yum"
    INSTALL_CMD="sudo yum install -y"
    UPDATE_CMD="sudo yum update -y"
else
    echo -e "${RED}Unsupported OS. This script works on Ubuntu/Debian or Amazon Linux.${NC}"
    exit 1
fi

echo -e "${GREEN}[1/6] Updating system packages...${NC}"
$UPDATE_CMD

echo ""
echo -e "${GREEN}[2/6] Installing Docker...${NC}"
if [ "$PKG_MANAGER" = "apt" ]; then
    $INSTALL_CMD docker.io docker-compose git curl
    sudo systemctl start docker
    sudo systemctl enable docker
else
    $INSTALL_CMD docker git
    sudo service docker start
    sudo chkconfig docker on
fi

# Add current user to docker group
sudo usermod -aG docker $USER
echo -e "${YELLOW}Note: You may need to log out and back in for docker group changes to take effect${NC}"

echo ""
echo -e "${GREEN}[3/6] Cloning repository...${NC}"
if [ -d "two-tier-devops-project" ]; then
    echo "Repository already exists. Pulling latest changes..."
    cd two-tier-devops-project
    git pull origin main
else
    git clone https://github.com/sadanandkonapur/two-tier-devops-project.git
    cd two-tier-devops-project
fi

echo ""
echo -e "${GREEN}[4/6] Configuring firewall (if UFW is installed)...${NC}"
if command -v ufw &> /dev/null; then
    sudo ufw allow 22/tcp
    sudo ufw allow 5000/tcp
    echo "Firewall rules added for ports 22 and 5000"
else
    echo "UFW not installed, skipping firewall configuration"
fi

echo ""
echo -e "${GREEN}[5/6] Starting application with Docker Compose...${NC}"
# Use newgrp to apply docker group without logout
newgrp docker << END
docker compose down 2>/dev/null || true
docker compose up -d
END

echo ""
echo -e "${GREEN}[6/6] Verifying deployment...${NC}"
sleep 5

# Check if containers are running
if docker compose ps | grep -q "Up"; then
    echo -e "${GREEN}✓ Containers are running successfully!${NC}"
else
    echo -e "${RED}✗ Some containers failed to start. Check logs with: docker compose logs${NC}"
    exit 1
fi

# Get public IP
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

echo ""
echo "================================================"
echo -e "${GREEN}Deployment Complete!${NC}"
echo "================================================"
echo ""
echo "Application is running at:"
echo -e "${GREEN}http://${PUBLIC_IP}:5000${NC}"
echo ""
echo "Useful commands:"
echo "  - View logs:     docker compose logs -f"
echo "  - Stop app:      docker compose down"
echo "  - Restart app:   docker compose restart"
echo "  - Check status:  docker compose ps"
echo ""
echo "Security Group Requirements:"
echo "  - Port 22 (SSH) - Your IP"
echo "  - Port 5000 (HTTP) - 0.0.0.0/0"
echo ""
echo -e "${YELLOW}Note: Make sure your AWS Security Group allows inbound traffic on port 5000${NC}"
echo ""
