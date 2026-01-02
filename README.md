# Two-Tier DevOps Project

A containerized two-tier application with Flask (web tier) and MySQL (database tier), featuring complete CI/CD pipeline with Jenkins.

## Architecture

```
┌─────────────────────────────────────────┐
│          Web Tier (Flask)               │
│     - REST API endpoints                │
│     - Web interface                     │
│     - Port: 5000                        │
└───────────────┬─────────────────────────┘
                │
                │ MySQL Connection
                ▼
┌─────────────────────────────────────────┐
│       Database Tier (MySQL)             │
│     - Data persistence                  │
│     - Port: 3306                        │
└─────────────────────────────────────────┘
```

## Prerequisites

- Docker (version 20.x or higher)
- Docker Compose (version 2.x or higher)
- Jenkins (for CI/CD pipeline)
- Git

## Project Structure

```
two-tier-devops-project/
├── app/
│   ├── app.py              # Flask application
│   ├── requirements.txt    # Python dependencies
│   └── templates/
│       └── index.html      # Frontend UI
├── Dockerfile              # Container image definition
├── docker-compose.yml      # Multi-container orchestration
├── init.sql                # Database initialization script
├── Jenkinsfile             # CI/CD pipeline definition
└── README.md               # Project documentation
```

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd two-tier-devops-project
```

### 2. Build and Run with Docker Compose

```bash
docker-compose up -d
```

This will:
- Build the Flask application image
- Pull MySQL 8.0 image
- Create and start both containers
- Initialize the database with sample data

### 3. Access the Application

- **Web Interface**: http://localhost:5000
- **API Health Check**: http://localhost:5000/health
- **MySQL Database**: localhost:3306

### 4. Verify Services

```bash
# Check running containers
docker-compose ps

# View application logs
docker-compose logs web

# View database logs
docker-compose logs mysql
```

## API Endpoints

| Method | Endpoint    | Description              |
|--------|-------------|--------------------------|
| GET    | /           | Web interface            |
| GET    | /health     | Health check endpoint    |
| GET    | /api/data   | Retrieve all items       |
| POST   | /api/data   | Add new item             |

## Development

### Local Development Setup

```bash
# Install Python dependencies
pip install -r app/requirements.txt

# Set environment variables
export DB_HOST=localhost
export DB_USER=root
export DB_PASSWORD=rootpassword
export DB_NAME=appdb

# Run Flask application
python app/app.py
```

### Building Docker Image Manually

```bash
docker build -t two-tier-app:latest .
```

### Running Individual Containers

```bash
# Run MySQL
docker run -d \
  --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=appdb \
  -p 3306:3306 \
  mysql:8.0

# Run Flask app
docker run -d \
  --name flask-app \
  --link mysql-db:mysql \
  -e DB_HOST=mysql \
  -p 5000:5000 \
  two-tier-app:latest
```

## CI/CD Pipeline

The project includes a complete Jenkins pipeline with the following stages:

1. **Checkout** - Clone source code
2. **Build** - Build Docker image
3. **Test** - Run automated tests
4. **Security Scan** - Vulnerability scanning with Trivy
5. **Push to Registry** - Push image to container registry
6. **Deploy** - Deploy to staging/production

### Setting up Jenkins Pipeline

1. Create a new Pipeline job in Jenkins
2. Point to this repository
3. Configure the following credentials:
   - `docker-credentials`: Docker registry credentials
4. Configure webhooks for automatic builds

### Environment Variables for Jenkins

```groovy
DOCKER_REGISTRY = 'your-registry-url'
DOCKER_IMAGE = 'two-tier-app'
```

## Configuration

### Environment Variables

| Variable      | Default   | Description                |
|---------------|-----------|----------------------------|
| DB_HOST       | mysql     | Database host              |
| DB_USER       | root      | Database user              |
| DB_PASSWORD   | password  | Database password          |
| DB_NAME       | appdb     | Database name              |

### Docker Compose Configuration

Modify [docker-compose.yml](docker-compose.yml) to customize:
- Port mappings
- Environment variables
- Volume mounts
- Network configuration

## Monitoring and Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f web
docker-compose logs -f mysql

# Check container health
docker-compose ps
```

## Troubleshooting

### Database Connection Issues

```bash
# Check MySQL is running
docker-compose ps mysql

# Test database connection
docker-compose exec mysql mysql -u root -prootpassword -e "SHOW DATABASES;"
```

### Application Not Starting

```bash
# Check application logs
docker-compose logs web

# Restart services
docker-compose restart
```

### Port Already in Use

```bash
# Stop existing containers
docker-compose down

# Check port usage
netstat -ano | findstr :5000
netstat -ano | findstr :3306
```

## Production Deployment

### Security Considerations

1. **Change Default Passwords**: Update all default passwords
2. **Use Secrets Management**: Store credentials in vault/secrets manager
3. **Enable SSL/TLS**: Configure HTTPS for web tier
4. **Network Segmentation**: Use proper network policies
5. **Resource Limits**: Set CPU and memory limits

### Scaling

```bash
# Scale web tier
docker-compose up -d --scale web=3

# Use orchestration platforms
# - Kubernetes
# - Docker Swarm
# - AWS ECS
```

## Maintenance

### Backup Database

```bash
docker-compose exec mysql mysqldump -u root -prootpassword appdb > backup.sql
```

### Restore Database

```bash
docker-compose exec -T mysql mysql -u root -prootpassword appdb < backup.sql
```

### Update Application

```bash
# Pull latest changes
git pull

# Rebuild and restart
docker-compose up -d --build
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Create an issue in the repository
- Contact: devops@example.com

## Acknowledgments

- Flask Framework
- MySQL Database
- Docker & Docker Compose
- Jenkins CI/CD
