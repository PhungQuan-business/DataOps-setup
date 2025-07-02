# DataOps Setup Guide

This repository contains configuration and installation scripts for setting up a complete DataOps environment with the following components:

- **Docker**: Container runtime platform
- **Apache Airflow**: Workflow orchestration platform
- **Apache Superset**: Business intelligence and data visualization platform
- **PostgreSQL**: Relational database with pgAdmin interface
- **MinIO**: S3-compatible object storage (Data Lake)

## 📋 Prerequisites

- Ubuntu/Debian-based Linux system (recommended)
- At least 4 cores CPU
- At least 16GB RAM (for optimal performance with Superset)
- At least 20GB free disk space
- Internet connection for downloading packages and Docker images
- Sudo privileges

## 🚀 Quick Start

### 1. System Preparation

First, update your OS settings and prepare the environment:

```bash
cd DataOps-setup/docker
chmod +x update_OS_setting.sh
./update_OS_setting.sh
```

This script will:

- Disable SELinux (if present)
- Disable firewalld (if present)
- Enable IPv4 IP forwarding
- Install necessary system packages

**⚠️ Important**: You may need to reboot your system after running this script for all changes to take effect.

### 2. Install Docker

Install Docker and Docker Compose:

```bash
cd DataOps-setup/docker
chmod +x install_docker.sh
./install_docker.sh
```

This script will:

- Remove any existing Docker installations
- Add Docker's official GPG key and repository
- Install Docker CE, Docker CLI, and Docker Compose
- Add your user to the docker group

**⚠️ Important**: After installation, log out and log back in for Docker group changes to take effect.

Verify Docker installation:

```bash
docker --version
docker compose version
docker ps
```

### 3. Set Up Storage Services

#### PostgreSQL Database

Start PostgreSQL with pgAdmin:

```bash
cd DataOps-setup/storage/database
docker compose -f database-docker-compose.yaml up -d
```

**Access Information:**

- **PostgreSQL**: `localhost:5432`
  - Username: `airc`
  - Password: `admin`
  - Database: `dataops`
- **pgAdmin Web UI**: `http://localhost:8081`
  - Email: `quan-airc@gmail.com`
  - Password: `admin`

#### MinIO Data Lake

Start MinIO object storage:

```bash
cd DataOps-setup/storage/datalake
docker compose -f datalake-docker-compose.yaml up -d
```

**Access Information:**

- **MinIO API**: `localhost:9000`
- **MinIO Console**: `http://localhost:9001`
  - Username: `admin`
  - Password: `password`

### 4. Install Apache Airflow

Install Airflow using Astronomer CLI:

```bash
cd DataOps-setup/airflow
chmod +x airflow-install.sh
./airflow-install.sh
```

This will install the Astronomer CLI, which provides an easy way to run Apache Airflow locally.

After installation, you can:

```bash
# Initialize a new Airflow project
astro dev init

# Start Airflow
astro dev start
```

**Default Access:**

- **Airflow Web UI**: `http://localhost:8080`
- **Username**: `admin`
- **Password**: `admin`

### 5. Install Apache Superset

Install and run Superset:

```bash
cd DataOps-setup/superset
chmod +x superset-install.sh
./superset-install.sh
```

This will:

- Clone the official Apache Superset repository
- Build and start Superset using Docker Compose

**⚠️ Performance Note**:

- Setup can take 15-20 minutes depending on your hardware
- If you have less than 16GB RAM, consider setting `BUILD_SUPERSET_FRONTEND_IN_DOCKER=false` and building frontend locally:
  ```bash
  export BUILD_SUPERSET_FRONTEND_IN_DOCKER=false
  # Then run the install script
  ```

**Default Access:**

- **Superset Web UI**: `http://localhost:8088`
- **Username**: `admin`
- **Password**: `admin`

## 🔧 Service Management

### Check Service Status

```bash
# Check all running containers
docker ps

# Check specific service logs
docker compose logs -f [service_name]
```

### Stop Services

```bash
# Stop database services
cd DataOps-setup/storage/database
docker compose down

# Stop data lake services
cd DataOps-setup/storage/datalake
docker compose down

# Stop Airflow (if using Astronomer)
astro dev stop

# Stop Superset
cd DataOps-setup/superset/superset
docker compose down
```

### Restart Services

```bash
# Restart with fresh containers
docker compose down && docker compose up -d

# Restart specific service
docker compose restart [service_name]
```

## 🌐 Service Ports Summary

| Service       | Port | URL                   | Purpose                   |
| ------------- | ---- | --------------------- | ------------------------- |
| PostgreSQL    | 5432 | -                     | Database connection       |
| pgAdmin       | 8081 | http://localhost:8081 | Database management       |
| MinIO API     | 9000 | -                     | Object storage API        |
| MinIO Console | 9001 | http://localhost:9001 | Object storage management |
| Airflow       | 8080 | http://localhost:8080 | Workflow orchestration    |
| Superset      | 8088 | http://localhost:8088 | Data visualization        |

## 🔐 Default Credentials

| Service    | Username            | Password |
| ---------- | ------------------- | -------- |
| PostgreSQL | airc                | admin    |
| pgAdmin    | quan-airc@gmail.com | admin    |
| MinIO      | admin               | password |
| Airflow    | admin               | admin    |
| Superset   | admin               | admin    |

**⚠️ Security Warning**: Change these default credentials in production environments!

## 📁 Data Persistence

All services are configured with persistent volumes:

- **PostgreSQL**: Data stored in `postgres_data` volume
- **pgAdmin**: Configuration stored in `pgadmin_data` volume
- **MinIO**: Data stored in `minio-data` volume
- **Airflow**: DAGs and logs persist in local directories
- **Superset**: Database and configurations persist in Docker volumes

## 🔍 Troubleshooting

### Common Issues

1. **Port Conflicts**: If ports are already in use, modify the port mappings in the respective docker-compose files.

2. **Permission Issues**: Ensure your user is in the docker group:

   ```bash
   sudo usermod -aG docker $USER
   # Log out and log back in
   ```

3. **Memory Issues**: For systems with limited RAM:

   - Increase swap space
   - Consider running services individually rather than all at once
   - For Superset, use local frontend build as mentioned above

4. **Docker Issues**:

   ```bash
   # Restart Docker service
   sudo systemctl restart docker

   # Clean up unused containers and images
   docker system prune -a
   ```

### Logs and Debugging

```bash
# View container logs
docker logs [container_name]

# View real-time logs
docker logs -f [container_name]

# Check container resource usage
docker stats
```

## 🔄 Updates and Maintenance

### Updating Services

```bash
# Pull latest images
docker compose pull

# Restart with updated images
docker compose down && docker compose up -d
```

### Backup Data

```bash
# Backup PostgreSQL
docker exec postgres_db pg_dump -U airc dataops > backup.sql

# Backup MinIO data
docker exec minio mc mirror /data /backup/minio-data
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Apache Superset Documentation](https://superset.apache.org/docs/intro)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MinIO Documentation](https://min.io/docs/)
- [Astronomer Documentation](https://docs.astronomer.io/)

## 🤝 Contributing

To add new services or modify existing configurations:

1. Create appropriate installation scripts in the service directory
2. Add Docker Compose configurations for containerized services
3. Update this README with setup instructions and access information
4. Test the complete setup process

## 📄 License

This setup guide and configurations are provided as-is for educational and development purposes.
