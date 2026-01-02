# Deployment Guide

## 🚀 Deployment Options

### Option 1: AWS EC2 (Recommended)
### Option 2: Azure VM
### Option 3: Google Cloud Compute Engine
### Option 4: Local Production Server

---

## 📦 Option 1: AWS EC2 Deployment

### Prerequisites
- AWS Account
- AWS CLI installed (optional)
- SSH client

### Step 1: Launch EC2 Instance

1. **Login to AWS Console**: https://console.aws.amazon.com/ec2/

2. **Launch Instance:**
   - Click "Launch Instance"
   - **Name**: `two-tier-devops-app`
   - **AMI**: Ubuntu Server 22.04 LTS or Amazon Linux 2023
   - **Instance Type**: `t2.small` (minimum) or `t2.medium` (recommended)
   - **Key Pair**: Create new or use existing (download .pem file)
   - **Network Settings:**
     - ✅ Allow SSH traffic from your IP
     - ✅ Allow HTTP traffic from internet
     - ✅ Allow HTTPS traffic from internet

3. **Configure Security Group:**
   Add these inbound rules:
   ```
   Type          Protocol  Port    Source          Description
   SSH           TCP       22      Your IP         SSH access
   Custom TCP    TCP       5000    0.0.0.0/0       Flask app
   Custom TCP    TCP       3306    10.0.0.0/16     MySQL (VPC only)
   HTTP          TCP       80      0.0.0.0/0       HTTP (optional)
   HTTPS         TCP       443     0.0.0.0/0       HTTPS (optional)
   ```

4. **Storage**: 20 GB minimum

5. **Launch Instance**

### Step 2: Connect to EC2

**Windows (PowerShell):**
```powershell
# Set permissions on key file (if needed)
icacls "C:\path\to\your-key.pem" /inheritance:r /grant:r "%USERNAME%:R"

# Connect via SSH
ssh -i "C:\path\to\your-key.pem" ubuntu@ec2-xx-xx-xx-xx.compute.amazonaws.com
```

**Linux/Mac:**
```bash
chmod 400 your-key.pem
ssh -i "your-key.pem" ubuntu@ec2-xx-xx-xx-xx.compute.amazonaws.com
```

### Step 3: Install Dependencies on EC2

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io docker-compose git

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER

# Re-login or run
newgrp docker

# Verify installation
docker --version
docker compose version
```

### Step 4: Deploy Application

```bash
# Clone repository
git clone https://github.com/sadanandkonapur/two-tier-devops-project.git
cd two-tier-devops-project

# Run with Docker Compose
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

### Step 5: Access Application

Open browser and visit:
```
http://your-ec2-public-ip:5000
```

Find your public IP in AWS console or run:
```bash
curl http://checkip.amazonaws.com
```

### Step 6: Configure Domain (Optional)

**Using Route 53:**
1. Register domain or use existing
2. Create hosted zone
3. Add A record pointing to EC2 public IP
4. Access via: `http://yourdomain.com:5000`

---

## 🔧 Option 2: Without Docker (Python Direct)

If Docker is not available:

```bash
# Install Python and dependencies
sudo apt install -y python3 python3-pip

# Clone repository
git clone https://github.com/sadanandkonapur/two-tier-devops-project.git
cd two-tier-devops-project/app

# Install requirements
pip3 install -r requirements.txt

# Run application
python3 app.py
```

**Run as background service:**
```bash
# Create systemd service
sudo nano /etc/systemd/system/flask-app.service
```

Add:
```ini
[Unit]
Description=Two-Tier Flask Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/two-tier-devops-project/app
ExecStart=/usr/bin/python3 app.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable flask-app
sudo systemctl start flask-app
sudo systemctl status flask-app
```

---

## 🌐 Option 3: Production Setup with Nginx

### Install Nginx as Reverse Proxy

```bash
# Install Nginx
sudo apt install -y nginx

# Configure Nginx
sudo nano /etc/nginx/sites-available/flask-app
```

Add configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Enable and restart:
```bash
sudo ln -s /etc/nginx/sites-available/flask-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

Now access via: `http://your-domain.com` (no port needed)

---

## 🔒 Option 4: Add SSL/HTTPS with Let's Encrypt

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com

# Auto-renewal (already configured)
sudo certbot renew --dry-run
```

Access via: `https://yourdomain.com`

---

## 📊 Option 5: AWS RDS for Production Database

Instead of SQLite, use managed MySQL:

1. **Create RDS Instance:**
   - Engine: MySQL 8.0
   - Instance: db.t3.micro (free tier)
   - Public access: No
   - VPC: Same as EC2

2. **Update docker-compose.yml:**
   ```yaml
   services:
     web:
       environment:
         - DB_HOST=your-rds-endpoint.rds.amazonaws.com
         - DB_USER=admin
         - DB_PASSWORD=your-password
         - DB_NAME=appdb
   ```

3. **Redeploy:**
   ```bash
   docker compose down
   docker compose up -d
   ```

---

## 🔄 Continuous Deployment with Jenkins

### Setup Jenkins on EC2

```bash
# Install Java
sudo apt install -y openjdk-11-jdk

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Access Jenkins: `http://ec2-ip:8080`

### Configure Pipeline

1. Create new Pipeline job
2. Point to GitHub repo
3. Use Jenkinsfile from repo
4. Configure webhooks for auto-deployment

---

## 📋 Monitoring and Maintenance

### Check Application Status
```bash
# Docker logs
docker compose logs -f web

# Resource usage
docker stats

# Restart services
docker compose restart
```

### System Monitoring
```bash
# Install monitoring tools
sudo apt install -y htop iotop nethogs

# Check system resources
htop

# Check disk space
df -h

# Check memory
free -h
```

### Backup Database
```bash
# Backup SQLite
docker compose exec web cp /app/app.db /app/backup-$(date +%Y%m%d).db

# For MySQL
docker compose exec mysql mysqldump -u root -p appdb > backup.sql
```

---

## 🚨 Troubleshooting

### Application not accessible
```bash
# Check if running
docker compose ps

# Check logs
docker compose logs

# Check firewall
sudo ufw status
sudo ufw allow 5000
```

### Port already in use
```bash
# Find process using port
sudo lsof -i :5000

# Kill process
sudo kill -9 <PID>
```

### Database connection issues
```bash
# Check database container
docker compose logs mysql

# Restart database
docker compose restart mysql
```

---

## 🎯 Quick Commands Reference

```bash
# Start application
docker compose up -d

# Stop application
docker compose down

# Restart application
docker compose restart

# View logs
docker compose logs -f

# Update from GitHub
git pull origin main
docker compose up -d --build

# Check status
docker compose ps
docker compose logs --tail=50
```

---

## 📞 Support

For issues:
1. Check logs: `docker compose logs`
2. Verify all containers running: `docker compose ps`
3. Check GitHub issues: https://github.com/sadanandkonapur/two-tier-devops-project/issues
