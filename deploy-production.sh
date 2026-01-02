#!/bin/bash
# Production Deployment Script with Nginx and SSL
# Run this on your production server

set -e

echo "================================================"
echo "Production Deployment with Nginx & SSL"
echo "================================================"
echo ""

# Prompt for domain name
read -p "Enter your domain name (e.g., example.com): " DOMAIN_NAME
read -p "Enter your email for SSL certificate: " EMAIL

if [ -z "$DOMAIN_NAME" ] || [ -z "$EMAIL" ]; then
    echo "Domain name and email are required!"
    exit 1
fi

echo ""
echo "Deploying for domain: $DOMAIN_NAME"
echo ""

# Update system
echo "[1/7] Updating system..."
sudo apt update && sudo apt upgrade -y

# Install dependencies
echo "[2/7] Installing dependencies..."
sudo apt install -y docker.io docker-compose git nginx certbot python3-certbot-nginx

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Clone repository
echo "[3/7] Cloning repository..."
cd ~
if [ -d "two-tier-devops-project" ]; then
    cd two-tier-devops-project
    git pull origin main
else
    git clone https://github.com/sadanandkonapur/two-tier-devops-project.git
    cd two-tier-devops-project
fi

# Start application
echo "[4/7] Starting application..."
newgrp docker << END
docker compose up -d
END

# Configure Nginx
echo "[5/7] Configuring Nginx..."
sudo tee /etc/nginx/sites-available/flask-app > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN_NAME www.$DOMAIN_NAME;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/flask-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# Setup SSL
echo "[6/7] Setting up SSL certificate..."
sudo certbot --nginx -d $DOMAIN_NAME -d www.$DOMAIN_NAME --non-interactive --agree-tos -m $EMAIL --redirect

# Setup auto-renewal
echo "[7/7] Configuring auto-renewal..."
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

echo ""
echo "================================================"
echo "Production Deployment Complete!"
echo "================================================"
echo ""
echo "Your application is now available at:"
echo "  https://$DOMAIN_NAME"
echo ""
echo "SSL certificate is installed and will auto-renew"
echo ""
echo "Useful commands:"
echo "  docker compose logs -f   # View logs"
echo "  docker compose ps        # Check status"
echo "  sudo nginx -t            # Test Nginx config"
echo "  sudo certbot renew --dry-run  # Test SSL renewal"
echo ""
