# Inception — Developer Documentation

This guide explains how to set up, build, and manage the Inception project as a developer.

---

## 1. Prerequisites

### Required Software
| Software | Version | Check Command |
|----------|---------|---------------|
| Docker Engine | 24+ | `docker --version` |
| Docker Compose | V2 | `docker compose version` |
| GNU Make | Any | `make --version` |
| Git | Any | `git --version` |

### System Requirements
- Linux-based OS (tested on Debian/Ubuntu)
- At least 4GB RAM
- 10GB free disk space
- Ports available: 443, 8080, 21, 21000-21010, 5000

### Docker Permissions
Add your user to the docker group to avoid using `sudo`:
```bash
sudo usermod -aG docker $USER
newgrp docker
```
> Note: The Makefile uses `sudo docker compose` by default. Remove `sudo` from the `COMPOSE` variable if you're in the docker group.

---

## 2. Project Structure

```
INCEPTION/
├── Makefile                    # Build automation
├── README.md                   # Project overview
├── secrets/                    # Credential files (not in git)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   ├── wp_user_password.txt
│   ├── ftp_password.txt
│   └── credentials.txt
└── srcs/
    ├── .env                    # Environment variables
    ├── docker-compose.yml      # Service orchestration
    └── requirements/
        ├── mariadb/            # Database service
        │   ├── dockerfile
        │   ├── conf/50-server.cnf
        │   └── tools/init-db.sh
        ├── wordpress/          # PHP-FPM application
        │   ├── dockerfile
        │   └── tools/init-wp.sh
        ├── nginx/              # Reverse proxy
        │   ├── dockerfile
        │   ├── conf/nginx.conf
        │   └── tools/init_ssl.sh
        └── bonus/
            ├── redis/          # Cache service
            ├── ftp/            # FTP server
            ├── adminer/        # DB admin UI
            └── website/        # Flask portfolio
```

---

## 3. Environment Setup

### Step 1: Clone/Navigate to Project
```bash
cd <path_to_docker_files>
```

### Step 2: Configure Environment Variables
Edit `srcs/.env`:
```env
# Database
MARIADB_DATABASE=wordpress
MARIADB_USER=wpuser

# Domain
DOMAIN_NAME=stdi-pum.42.fr

# WordPress
WP_TITLE="Inceptional"
WP_ADMIN_USER=ste
WP_ADMIN_EMAIL=stdi-pum@student.42berlin.fr
WP_USER_LOGIN=user_ste
WP_USER_EMAIL=berryfeels@gmail.com
```

### Step 3: Set Up Secrets
Create/edit files in `secrets/`:

| File | Content |
|------|---------|---------|---------||
| `db_password.txt` | WordPress DB user password |
| `db_root_password.txt` | MariaDB root password |
| `wp_admin_password.txt` | WP admin password |
| `wp_user_password.txt` | WP regular user password |
| `ftp_password.txt` | FTP user password |
| `credentials.txt` | Format: `user:pass` |

> ⚠️ Each file should contain ONLY the password, no newline at the end if possible.

### Step 4: Add Domain to Hosts
```bash
echo "127.0.0.1 stdi-pum.42.fr" | sudo tee -a /etc/hosts
```

---

## 4. Building and Launching

### Using Makefile (Recommended)

| Command | Description |
|---------|-------------|
| `make` | Build and start all services |
| `make build` | Build/rebuild images only |
| `make up` | Start services (builds if needed) |
| `make start` | Start stopped containers |
| `make stop` | Stop containers without removing |
| `make down` | Stop and remove containers |
| `make logs` | Follow container logs |
| `make status` | Show container status |

### Using Docker Compose Directly
```bash
cd srcs
sudo docker compose up -d --build
sudo docker compose logs -f
sudo docker compose down
```

### Build a Single Service
```bash
sudo docker compose up -d --build <service_name>
# Example:
sudo docker compose up -d --build adminer
```

---

## 5. Container Management

### View All Containers
```bash
sudo docker ps -a
```

### Access Container Shell
```bash
sudo docker exec -it <container_name> /bin/bash
# Examples:
sudo docker exec -it mariadb /bin/bash
sudo docker exec -it wordpress /bin/bash
sudo docker exec -it nginx /bin/sh
```

### View Container Logs
```bash
sudo docker logs <container_name>
sudo docker logs -f <container_name>  # Follow mode
```

### Restart a Container
```bash
sudo docker restart <container_name>
```

### Inspect Container
```bash
sudo docker inspect <container_name>
```

---

## 6. Volume Management

### Volume Locations
Data persists in bind mounts on the host:

| Volume | Host Path | Container Path |
|--------|-----------|----------------|
| `mariadb_data` | `/home/stdi-pum/data/mariadb` | `/var/lib/mysql` |
| `wordpress_data` | `/home/stdi-pum/data/wordpress` | `/var/www/html` |

### List Volumes
```bash
sudo docker volume ls
```

### Inspect Volume
```bash
sudo docker volume inspect srcs_mariadb_data
sudo docker volume inspect srcs_wordpress_data
```

### Access Data Directly
```bash
ls -la /home/stdi-pum/data/mariadb/
ls -la /home/stdi-pum/data/wordpress/
```

### Clear Volumes (Reset Data)
```bash
make fclean
# This removes:
# - All containers
# - All images
# - All volumes
# - /home/stdi-pum/data/ directory
```

---

## 7. Network Configuration

### Network Name
The services use a custom bridge network called `inceptional`.

### View Network
```bash
sudo docker network ls
sudo docker network inspect inceptional
```

### Service Discovery
Containers can reach each other by hostname:
- `mariadb:3306` — Database
- `wordpress:9000` — PHP-FPM
- `redis:6379` — Cache
- `nginx:443` — Reverse proxy

### Exposed Ports

| Service | Internal Port | External Port |
|---------|---------------|---------------|
| nginx | 443 | 443 |
| adminer | 8080 | 8080 |
| ftp | 21 | 21 |
| ftp (passive) | 21000-21010 | 21000-21010 |
| website | 5000 | 5000 |
| mariadb | 3306 | Not exposed |
| wordpress | 9000 | Not exposed |
| redis | 6379 | Not exposed |

---

## 8. Testing & Debugging

### Overall Status
```bash
docker compose -f srcs/docker-compose.yml ps
```
Verify every service is `Up`.

### Resource Monitoring
```bash
docker stats
```
Watch CPU/memory metrics for anomalies or crash loops.

### Network Inspection
```bash
docker network inspect inceptional
```
Confirm IP assignments and that every container is attached.

### DNS Reachability Between Containers
```bash
docker exec -it nginx ping -c 3 wordpress
docker exec -it wordpress ping -c 3 mariadb
```

### Port Binding Check on Host
```bash
ss -tlnp | grep -E '(:443|:8080|:5000|:21)'
```
Confirms exposed ports are listening.

### Endpoint Probes
```bash
# WordPress/Nginx
curl -k https://stdi-pum.42.fr
curl -k https://localhost

# Adminer
curl http://localhost:8080

# Flask site
curl http://localhost:5000
```

### Database Connectivity
```bash
docker exec -it mariadb mysql -u wpuser -p wordpress -e "SHOW TABLES;"
# Enter password from secrets/db_password.txt
```

### Redis Ping
```bash
docker exec -it redis redis-cli PING
```

### FTP Control Channel
```bash
# Check ports are reachable
nc -vz localhost 21
nc -vz localhost 21000

# Test with lftp (use password from secrets/ftp_password.txt)
lftp -u ftpuser localhost
```

### TLS Certificate Details
```bash
echo | openssl s_client -connect stdi-pum.42.fr:443 -servername stdi-pum.42.fr
```

### Verify TLS
```bash
curl -kv https://localhost:443 2>&1 | grep -E "(SSL|TLS|cipher)"
```

### Log Tail for All Services
```bash
docker compose -f srcs/docker-compose.yml logs -f nginx mariadb wordpress redis ftp adminer website
# Ctrl+C to exit
```

### Wipe Database Files
```bash
docker compose -f srcs/docker-compose.yml down -v
```

---

### FTP Testing

```bash
# List files in WordPress directory (use password from secrets/ftp_password.txt)
curl -u ftpuser:<FTP_PASSWORD> ftp://localhost:21/

# Upload a test file
echo "test" > testfile.txt
curl -u ftpuser:<FTP_PASSWORD> -T testfile.txt ftp://localhost:21/

# Enter WordPress container and verify files
docker exec -it wordpress bash
ls -la /var/www/html/

# Create a test file inside WordPress
echo "test ftp" > /var/www/html/test-ftp.txt

# Enter FTP container and verify
docker exec -it ftp bash
ls -la /var/www/html/
cat /var/www/html/test-ftp.txt

# Verify volume sharing
docker exec ftp touch /var/www/html/created-by-ftp.txt
docker exec wordpress ls -la /var/www/html/created-by-ftp.txt
```

---

### Redis Testing

```bash
# Test ping
docker exec redis redis-cli PING

# See WordPress cache keys
docker exec redis redis-cli KEYS '*'

# Statistics
docker exec redis redis-cli INFO stats

# Check if WordPress is using Redis
docker exec wordpress wp redis status --allow-root --path=/var/www/html
```

---

### Rebuild and Restart Single Services

```bash
# Rebuild and restart a single service
docker-compose up -d --build <service_name>

# Example for adminer
docker-compose up -d --build adminer
```

| Command | Description |
|---------|-------------|
| `docker-compose build adminer` | Rebuild image only (no restart) |
| `docker-compose up -d --build adminer` | Rebuild + restart |
| `docker-compose up -d --force-recreate adminer` | Recreate container (no rebuild) |
| `docker-compose up -d --build --no-deps adminer` | Rebuild without restarting dependencies |

---

### MariaDB Issues
```bash
# Check healthcheck status
sudo docker inspect --format='{{.State.Health.Status}}' mariadb

# Check if MariaDB process is running
sudo docker exec mariadb pgrep mysqld

# Access MySQL CLI (enter password from secrets/db_root_password.txt)
sudo docker exec -it mariadb mysql -u root -p

# Check database exists
sudo docker exec mariadb mysql -u root -p -e "SHOW DATABASES;"
```

### WordPress Issues
```bash
# Check PHP-FPM status
sudo docker exec wordpress ps aux | grep php

# Check wp-config.php
sudo docker exec wordpress cat /var/www/html/wp-config.php

# Test database connection
sudo docker exec wordpress mysqladmin ping -h mariadb -u wpuser -p
```

### Nginx Issues
```bash
# Test configuration
sudo docker exec nginx nginx -t

# Check SSL certificate
sudo docker exec nginx ls -la /etc/nginx/ssl/

# View access logs
sudo docker exec nginx cat /var/log/nginx/access.log
```

### Common Fixes
```bash
# Container keeps restarting
sudo docker logs <container_name>

# Permission issues
sudo chown -R $USER:$USER /home/stdi-pum/data/

# Complete reset
make fclean && make
```

---

## 9. Modifying Services

### Changing Dockerfiles
1. Edit the dockerfile in `srcs/requirements/<service>/`
2. Rebuild: `make build` or `sudo docker compose up -d --build <service>`

### Changing Configuration
1. Edit config files in `srcs/requirements/<service>/conf/`
2. Rebuild the service

### Adding Environment Variables
1. Add to `srcs/.env`
2. Reference in `docker-compose.yml`:
   ```yaml
   environment:
     NEW_VAR: ${NEW_VAR}
   ```
3. Rebuild

### Adding a New Service
1. Create directory: `srcs/requirements/bonus/newservice/`
2. Add `dockerfile`, `conf/`, and `tools/`
3. Add service to `docker-compose.yml`
4. Rebuild: `make`

---

## 10. Key Files Reference

| File | Purpose |
|------|---------|
| `Makefile` | Build automation and shortcuts |
| `srcs/docker-compose.yml` | Service definitions and orchestration |
| `srcs/.env` | Environment variables |
| `srcs/requirements/mariadb/tools/init-db.sh` | Database initialization |
| `srcs/requirements/wordpress/tools/init-wp.sh` | WordPress setup with WP-CLI |
| `srcs/requirements/nginx/tools/init_ssl.sh` | SSL certificate generation |
| `srcs/requirements/nginx/conf/nginx.conf` | Nginx/TLS configuration |
| `srcs/requirements/mariadb/conf/50-server.cnf` | MariaDB configuration |
| `srcs/requirements/bonus/redis/conf/redis.conf` | Redis configuration |
| `srcs/requirements/bonus/ftp/conf/vsftpd.conf` | FTP server configuration |

---

## 11. Quick Command Reference

```bash
# === BUILD & RUN ===
make                    # Build and start everything
make build              # Build images only
make up                 # Start services
make down               # Stop and remove containers

# === CLEANUP ===
make clean              # Remove containers and volumes
make fclean             # Full cleanup including data
make re                 # Rebuild from scratch

# === MONITORING ===
make logs               # Follow all logs
make status             # Container status
sudo docker ps -a       # All containers

# === SINGLE SERVICE ===
sudo docker compose up -d --build mariadb
sudo docker logs -f mariadb
sudo docker restart mariadb
sudo docker exec -it mariadb /bin/bash

# === VOLUMES ===
sudo docker volume ls
sudo docker volume inspect srcs_mariadb_data
ls -la /home/stdi-pum/data/

# === NETWORK ===
sudo docker network inspect inceptional
```
