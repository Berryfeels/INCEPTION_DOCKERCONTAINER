*This project has been created as part of the 42 curriculum by stefanodipuma.*

## Description
Inception is a self-contained WordPress stack orchestrated with Docker Compose. It packages an SSL-terminated Nginx reverse proxy, a hardened MariaDB instance, PHP-FPM-based WordPress, and several bonus services (Redis cache, FTP gateway, Adminer UI, and a personal Flask website). The goal is to prove mastery of Docker images, volumes, networks, secrets, and service orchestration without relying on prebuilt Compose bundles.

## Project Description
### Architecture Overview
- **Compose topology**: [srcs/docker-compose.yml](srcs/docker-compose.yml) wires seven services on the isolated `intra` bridge network while exposing only HTTP(S), FTP, Adminer, and the portfolio site to the host.
- **Core services**:
  - `mariadb` builds from [requirements/mariadb/dockerfile](srcs/requirements/mariadb/dockerfile) and bootstraps via [tools/init-db.sh](srcs/requirements/mariadb/tools/init-db.sh).
  - `wordpress` (PHP-FPM) comes from [requirements/wordpress/dockerfile](srcs/requirements/wordpress/dockerfile) with configuration in [tools/wp-config.php](srcs/requirements/wordpress/tools/wp-config.php).
  - `nginx` SSL gateway originates from [requirements/nginx/dockerfile](srcs/requirements/nginx/dockerfile) and the TLS-aware [conf/nginx.conf](srcs/requirements/nginx/conf/nginx.conf).
- **Bonus services**: Redis cache, FTP uploader, Adminer dashboard, and a Flask portfolio described in the *Services* section reuse images under [requirements/bonus](srcs/requirements/bonus).
- **Stateful components**: Named volumes `mariadb_data` and `wordpress_data` persist database tables and WordPress uploads/themes across container restarts.

### Docker Usage & Source Layout
- Every image is built from Debian Bookworm to satisfy the *no Docker Hub* rule.
- Service-specific configuration lives under `conf/`, while entrypoint scripts reside in `tools/` (for example, [requirements/nginx/tools/init_ssl.sh](srcs/requirements/nginx/tools/init_ssl.sh) for certificate generation).
- Secrets are injected through Docker secrets defined in [srcs/docker-compose.yml](srcs/docker-compose.yml) and stored in plain-text files under [secrets/](secrets).
- The `Makefile` at the repository root wraps common Compose commands for convenience.

### Design Choices
- **TLS everywhere**: Self-signed certificates are created at build time so the reverse proxy only exposes HTTPS ([init_ssl.sh](srcs/requirements/nginx/tools/init_ssl.sh)).
- **Separation of concerns**: PHP-FPM runs inside the WordPress container, while Nginx proxies requests and hands off `.php` files via FastCGI, mirroring production-ready architectures.
- **Automated database hardening**: [init-db.sh](srcs/requirements/mariadb/tools/init-db.sh) removes anonymous/test accounts, sets custom users, and reads passwords from secrets so credentials never live in the image.
- **Extensibility via bonus services**: Redis is preconfigured with authentication, FTP provides a controlled write path to `/var/www/html`, Adminer offers GUI DB access, and a Flask site demonstrates how to add arbitrary projects to the same network.

### Technology Comparisons
- **Virtual Machines vs Docker**: Containers share the host kernel, so spinning up WordPress + MariaDB consumes far fewer resources than separate VMs. They build in seconds (single `docker compose up`) versus minutes-long VM provisioning, yet still allow reproducible environments checked into source control.
- **Secrets vs Environment Variables**: `.env` variables (e.g., `MARIADB_DATABASE`, `DOMAIN_NAME`) configure non-sensitive metadata, while high-risk credentials (`db_password`, `db_root_password`, `credentials`) travel through Docker secrets (see [secrets/db_password.txt](secrets/db_password.txt)). Secrets are mounted as in-memory files at runtime, avoiding leaks via `docker inspect` or process tables.
- **Docker Network vs Host Network**: Using the custom bridge `intra` isolates inter-service traffic and allows name-based discovery (`fastcgi_pass wordpress:9000` in [nginx.conf](srcs/requirements/nginx/conf/nginx.conf)). Only selected ports (80/443/21/21000-21010/8080/5000) are published, unlike host networking which would expose every daemon.
- **Docker Volumes vs Bind Mounts**: Named volumes (`mariadb_data`, `wordpress_data`) are portable and managed by Docker, providing consistent ownership and SELinux/AppArmor labeling. Bind mounts could inadvertently inherit host permissions and risk accidental edits; volumes keep stateful data encapsulated yet persistent.

## Instructions
### Prerequisites
- Docker Engine 24+ and Docker Compose V2 (bundled with Docker Desktop on macOS).
- GNU Make (already available on macOS) if you want shortcut targets from [Makefile](Makefile).

### Secrets & Environment
1. Populate the secret files under [secrets/](secrets) (default examples already exist):
   - `db_root_password.txt`
   - `db_password.txt`
   - `credentials.txt` (format `username:password` consumed by WordPress for initial admin setup).
2. Create `srcs/.env` with at least:
   ```env
   DOMAIN_NAME=example.local
   MARIADB_DATABASE=wordpress
   MARIADB_USER=wpuser
   ```
   Add any other variables you wish to reuse in Compose.

### Build & Run
- `make` or `make up`: build all images and start the stack in detached mode.
- `make build`: rebuild images after configuration changes.
- `make logs`: follow the tail of aggregated service logs.

### Lifecycle Management
- `make down`: stop containers but keep volumes.
- `make clean`: drop containers, anonymous volumes, and the bridge network.
- `make fclean`: additionally delete images and orphans for a pristine state.
- `make re`: rebuild from scratch.

### Access Points
- WordPress: https://localhost (Nginx handles HTTP→HTTPS redirects).
- Adminer: http://localhost:8080 (connect to host `mariadb`, user `wpuser` or `wpmanager`).
- FTP: `ftpuser/ftppass` on port 21 (passive ports 21000-21010 must be open locally).
- Redis: internal only (`redis:6379`, password `redispass` per [redis.conf](srcs/requirements/bonus/redis/conf/redis.conf)).
- Portfolio site: http://localhost:5000.

### Troubleshooting
- Certificate CN is derived from `DOMAIN_NAME`. Browsers will warn about self-signed certs; accept the risk for local testing.
- If `wordpress` cannot reach `mariadb`, ensure the secrets contain matching passwords and the database volume is clean (`make fclean`).
- FTP passive mode requires the host firewall to allow 21000-21010.

## Services
- **mariadb**: Configured via [50-server.cnf](srcs/requirements/mariadb/conf/50-server.cnf) to allow remote clients, UTF-8 MB4, and tuned InnoDB buffers. Initialization script grants two accounts (`wpuser`, `wpmanager`).
- **wordpress**: Ships with official tarball download; `wp-config.php` reads the DB password from `/run/secrets/db_password` so it never lands in the repository.
- **nginx**: Generates a self-signed certificate and enforces HSTS, security headers, and caching rules. Acts purely as reverse proxy/FastCGI front-end.
- **redis**: Optional cache service with password protection and memory eviction tuned in [redis.conf](srcs/requirements/bonus/redis/conf/redis.conf).
- **ftp**: Based on vsftpd with jailed local user rooted in `/var/www/html`, enabling drag-and-drop theme/plugin uploads while respecting WordPress volume permissions.
- **adminer**: Lightweight PHP app fronted by Nginx for DB administration without exposing the DB port to the host.
- **website**: Simple Flask portfolio ([app.py](srcs/requirements/bonus/website/src/app.py)) served via [start-website.sh](srcs/requirements/bonus/website/tools/start-website.sh); demonstrates how to onboard additional microservices.

## Resources
- [Docker documentation](https://docs.docker.com/)
- [Docker Compose specification](https://docs.docker.com/compose/compose-file/)
- [MariaDB knowledge base](https://mariadb.com/kb/en/)
- [WordPress Codex](https://wordpress.org/documentation/)
- [Nginx reference](https://nginx.org/en/docs/)
- [Redis documentation](https://redis.io/docs/latest/)
- **AI usage**: GitHub Copilot (GPT-5.1-Codex) assisted in summarizing container configurations, cross-checking service interactions, and drafting this README. All configurations and scripts were reviewed manually afterward.
