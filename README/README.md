*This project has been created as part of the 42 curriculum by stdi-pum.*

## Description
Inception is a self-contained WordPress stack orchestrated with Docker Compose. It packages an SSL-terminated Nginx reverse proxy, a hardened MariaDB instance, PHP-FPM-based WordPress, and several bonus services (Redis cache, FTP gateway, Adminer UI, and a personal Flask website). The goal is to prove mastery of Docker images, volumes, networks, secrets, and service orchestration without relying on prebuilt Compose bundles.

## Project Description
### Architecture Overview
- **Compose topology**: [docker-compose.yml](../srcs/docker-compose.yml) wires seven services on the isolated `inceptional` bridge network while exposing only HTTPS (443), FTP (21, 21000-21010), Adminer (8080), and the portfolio site (5000) to the host.
- **Core services**:
  - `mariadb` builds from [requirements/mariadb/dockerfile](../srcs/requirements/mariadb/dockerfile) and bootstraps via [tools/init-db.sh](../srcs/requirements/mariadb/tools/init-db.sh).
  - `wordpress` (PHP-FPM) comes from [requirements/wordpress/dockerfile](../srcs/requirements/wordpress/dockerfile) with WP-CLI-based installation in [tools/init-wp.sh](../srcs/requirements/wordpress/tools/init-wp.sh).
  - `nginx` SSL gateway originates from [requirements/nginx/dockerfile](../srcs/requirements/nginx/dockerfile) and the TLS-aware [conf/nginx.conf](../srcs/requirements/nginx/conf/nginx.conf).
- **Bonus services**: Redis cache, FTP uploader, Adminer dashboard, and a Flask portfolio described in the *Services* section reuse images under [requirements/bonus](../srcs/requirements/bonus).
- **Stateful components**: Named volumes `mariadb_data` and `wordpress_data` use bind mounts to `/home/stdi-pum/data/mariadb` and `/home/stdi-pum/data/wordpress` to persist database tables and WordPress uploads/themes across container restarts.

### Docker Usage & Source Layout
- Every image is built from Debian Bookworm to satisfy the *no Docker Hub* rule.
- Service-specific configuration lives under `conf/`, while entrypoint scripts reside in `tools/` (for example, [requirements/nginx/tools/init_ssl.sh](../srcs/requirements/nginx/tools/init_ssl.sh) for certificate generation).
- Secrets are injected through Docker secrets defined in [srcs/docker-compose.yml](../srcs/docker-compose.yml) and stored in plain-text files under [secrets/](../secrets): `db_password.txt`, `db_root_password.txt`, `credentials.txt`, `wp_admin_password.txt`, `wp_user_password.txt`, and `ftp_password.txt`.
- The `Makefile` at the repository root wraps common Compose commands for convenience and uses `sudo docker compose`.

### Design Choices
- **TLS everywhere**: Self-signed certificates are created at build time so the reverse proxy only exposes HTTPS with TLSv1.2/TLSv1.3 ([init_ssl.sh](../srcs/requirements/nginx/tools/init_ssl.sh)).
- **Separation of concerns**: PHP-FPM runs inside the WordPress container, while Nginx proxies requests and hands off `.php` files via FastCGI, mirroring production-ready architectures.
- **Automated database hardening**: [init-db.sh](../srcs/requirements/mariadb/tools/init-db.sh) sets custom users (`wpuser`) and reads passwords from secrets so credentials never live in the image.
- **Extensibility via bonus services**: Redis is preconfigured with memory eviction (256mb, allkeys-lru), FTP provides a controlled write path to `/var/www/html`, Adminer offers GUI DB access, and a Flask site demonstrates how to add arbitrary projects to the same network.

### Technology Comparisons
- **Virtual Machines vs Docker**: Containers share the host kernel, so spinning up WordPress + MariaDB consumes far fewer resources than separate VMs. They build in seconds (single `docker compose up`) versus minutes-long VM provisioning, yet still allow reproducible environments checked into source control.
- **Secrets vs Environment Variables**: `.env` variables (e.g., `MARIADB_DATABASE`, `MARIADB_USER`, `DOMAIN_NAME`, `WP_TITLE`, `WP_ADMIN_USER`, `WP_ADMIN_EMAIL`) configure non-sensitive metadata, while high-risk credentials (`db_password`, `db_root_password`, `wp_admin_password`, `wp_user_password`, `ftp_password`) travel through Docker secrets. Secrets are mounted as in-memory files at runtime, avoiding leaks via `docker inspect` or process tables.
- **Docker Network vs Host Network**: Using the custom bridge `inceptional` (aliased as `intra` in service configs) isolates inter-service traffic and allows name-based discovery (`fastcgi_pass wordpress:9000` in [nginx.conf](../srcs/requirements/nginx/conf/nginx.conf)). Only selected ports (443/21/21000-21010/8080/5000) are published, unlike host networking which would expose every daemon.
- **Docker Volumes vs Bind Mounts**: Named volumes (`mariadb_data`, `wordpress_data`) use bind mounts to `/home/stdi-pum/data/`, allowing direct host access while maintaining consistent ownership. The `Makefile` creates these directories automatically via the `create-dirs` target.

## Instructions
### Prerequisites
- Docker Engine 24+ and Docker Compose V2 (bundled with Docker Desktop on macOS).
- GNU Make (already available on macOS) if you want shortcut targets from [Makefile](../Makefile).

### Secrets & Environment
1. Populate the secret files under [secrets/](../secrets) (default examples already exist):
   - `db_root_password.txt`
   - `db_password.txt`
   - `credentials.txt` (format `username:password` consumed by WordPress).
   - `wp_admin_password.txt`
   - `wp_user_password.txt`
   - `ftp_password.txt`
2. Create `srcs/.env` with at least:
   ```env
   DOMAIN_NAME=stdi-pum.42.fr
   MARIADB_DATABASE=wordpress
   MARIADB_USER=wpuser
   WP_TITLE="Inceptional"
   WP_ADMIN_USER=ste
   WP_ADMIN_EMAIL=stdi-pum@student.42berlin.fr
   WP_USER_LOGIN=user_ste
   WP_USER_EMAIL=berryfeels@gmail.com
   ```
   Add any other variables you wish to reuse in Compose.

### Build & Run
- `make` or `make up`: build all images and start the stack in detached mode.
- `make build`: rebuild images after configuration changes.
- `make logs`: follow the tail of aggregated service logs.

### Lifecycle Management
- `make down`: stop containers but keep volumes.
- `make clean`: drop containers, anonymous volumes, and the bridge network.
- `make fclean`: additionally delete images, orphans, and the `/home/stdi-pum/data` directory for a pristine state.
- `make re`: rebuild from scratch.

### Access Points
- WordPress: https://stdi-pum.42.fr (Nginx handles HTTPS on port 443).
- Adminer: http://localhost:8080 (connect to host `mariadb`, user `wpuser`).
- FTP: `ftpuser/ftppass` on port 21 (passive ports 21000-21010 must be open locally).
- Redis: internal only (`redis:6379`, no password, protected-mode off per [redis.conf](../srcs/requirements/bonus/redis/conf/redis.conf)).
- Portfolio site: http://localhost:5000.

### Troubleshooting
- Certificate CN is derived from `DOMAIN_NAME`. Browsers will warn about self-signed certs; accept the risk for local testing.
- If `wordpress` cannot reach `mariadb`, ensure the secrets contain matching passwords and the database volume is clean (`make fclean`).
- FTP passive mode requires the host firewall to allow 21000-21010.

## Services
- **mariadb**: Configured via [50-server.cnf](../srcs/requirements/mariadb/conf/50-server.cnf) to allow remote clients, UTF-8 MB4, and tuned InnoDB buffers. Initialization script [init-db.sh](../srcs/requirements/mariadb/tools/init-db.sh) creates the `wordpress` database and grants access to `wpuser`.
- **wordpress**: Uses WP-CLI in [init-wp.sh](../srcs/requirements/wordpress/tools/init-wp.sh) to download WordPress core, create `wp-config.php`, and set up admin/user accounts. DB password is read from `/run/secrets/db_password` so it never lands in the repository.
- **nginx**: Generates a self-signed certificate via [init_ssl.sh](../srcs/requirements/nginx/tools/init_ssl.sh) and enforces HSTS, security headers (X-Frame-Options, X-Content-Type-Options, X-XSS-Protection), and gzip compression. Acts purely as reverse proxy/FastCGI front-end on port 443.
- **redis**: Optional cache service with memory eviction (256mb maxmemory, allkeys-lru policy) tuned in [redis.conf](../srcs/requirements/bonus/redis/conf/redis.conf). Protected mode disabled for internal network access.
- **ftp**: Based on vsftpd with jailed local user (`ftpuser`) rooted in `/var/www/html`, enabling drag-and-drop theme/plugin uploads while respecting WordPress volume permissions. Configured via [vsftpd.conf](../srcs/requirements/bonus/ftp/conf/vsftpd.conf).
- **adminer**: Lightweight PHP app fronted by Nginx for DB administration without exposing the DB port to the host. Runs on port 8080.
- **website**: Simple Flask portfolio ([app.py](../srcs/requirements/bonus/website/src/app.py)) served via [start-website.sh](../srcs/requirements/bonus/website/tools/start-website.sh) on port 5000; demonstrates how to onboard additional microservices.

## Resources
- [Docker documentation](https://docs.docker.com/)
- [Docker Compose specification](https://docs.docker.com/compose/compose-file/)
- [MariaDB knowledge base](https://mariadb.com/kb/en/)
- [WordPress Codex](https://wordpress.org/documentation/)
- [Nginx reference](https://nginx.org/en/docs/)
- [Redis documentation](https://redis.io/docs/latest/)
- **AI usage**: GitHub Copilot (Claude Opus 4.5) assisted in summarizing container configurations, cross-checking service interactions, and drafting this README. All configurations and scripts were reviewed manually afterward.
