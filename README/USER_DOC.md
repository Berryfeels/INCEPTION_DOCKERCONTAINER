# Inception — User Documentation

This guide explains how to use the Inception WordPress stack as an end user or administrator.

---

## 1. Services Overview

The Inception stack provides the following services:

| Service | Description | Access |
|---------|-------------|--------|
| **WordPress** | Content management system for your website | https://stdi-pum.42.fr |
| **Adminer** | Web-based database administration panel | http://localhost:8080 |
| **FTP** | File transfer for uploading themes/plugins | Port 21 |
| **Redis** | Performance cache (internal, automatic) | Not directly accessible |
| **Flask Website** | Personal portfolio site | http://localhost:5000 |

---

## 2. Starting and Stopping the Project

### Start the Stack
```bash
make
# or
make up
```
This builds all containers (if needed) and starts the services in the background.

### Stop the Stack
```bash
make stop
```
This stops all containers but **preserves your data** (database, uploads).

### Full Reset (Caution!)
```bash
make fclean
```
This removes **everything**: containers, images, volumes, and data. Use only when you want a completely fresh start.

---

## 3. Accessing the Website

### WordPress Site
1. Open your browser and navigate to: **https://stdi-pum.42.fr**
2. Accept the self-signed certificate warning (this is expected for local development)
3. You'll see the WordPress site titled "Inceptional"

### WordPress Admin Panel
1. Go to: **https://stdi-pum.42.fr/wp-admin**
2. Log in with:
   - **Username**: <admin_name> or <user>
   - **Password**: (see credentials section below)

---

## 4. Accessing the Database (Adminer)

Adminer provides a web interface to view and manage the database.

1. Open: **http://localhost:8080**
2. Fill in the login form:
   - **System**: MySQL
   - **Server**: `mariadb`
   - **Username**: `wpuser`
   - **Password**: (see `secrets/db_password.txt`)
   - **Database**: `wordpress`

**Quick access URL** (pre-fills some fields):
```
http://localhost:8080/?server=mariadb&username=wpuser&db=wordpress
```

---

## 5. Locating and Managing Credentials

All sensitive credentials are stored in the `secrets/` folder:

| File | Purpose |
|------|---------|
| `db_password.txt` | Database password for `wpuser` |
| `db_root_password.txt` | Database root password |
| `wp_admin_password.txt` | WordPress admin password |
| `wp_user_password.txt` | WordPress regular user password |
| `ftp_password.txt` | FTP user password |
| `credentials.txt` | General credentials file |

### Changing Credentials
1. Edit the appropriate file in `secrets/`
2. Run `make fclean && make` to rebuild with new credentials

> ⚠️ **Important**: Changing database passwords after initial setup requires a full reset (`make fclean`).

---

## 6. FTP Access

Upload files directly to WordPress using FTP:

| Setting | Value |
|---------|-------|
| **Host** | `localhost` |
| **Port** | `21` |
| **Username** | `ftpuser` |
| **Password** | (see `secrets/ftp_password.txt`) |
| **Directory** | `/var/www/html` (WordPress root) |

Use any FTP client (FileZilla, Cyberduck, etc.) to connect.

---

## 7. Checking Service Status

### View Running Containers
```bash
make status
```

### View Live Logs
```bash
make logs
```
Press `Ctrl+C` to exit the log view.

### Check Individual Service
```bash
sudo docker ps | grep <service-name>
```
Replace `<service-name>` with: `mariadb`, `wordpress`, `nginx`, `redis`, `ftp`, `adminer`, or `website`.

### Expected Healthy State

All containers should show as "Up" with the following ports:

| Container | Ports |
|-----------|-------|
| nginx | 443 |
| adminer | 8080 |
| ftp | 21, 21000-21010 |
| website | 5000 |
| mariadb | (internal only) |
| wordpress | (internal only) |
| redis | (internal only) |

---

## 8. Troubleshooting

### "Connection Refused" on WordPress
- Wait 30 seconds after starting — MariaDB needs time to initialize
- Check logs: `make logs`

### Certificate Warning in Browser
- This is normal for self-signed certificates
- Click "Advanced" → "Proceed to site"

### Can't Connect to Adminer
- Ensure MariaDB is healthy: `sudo docker ps | grep mariadb`
- Verify password matches `secrets/db_password.txt`

### FTP Connection Failed
- Ensure passive ports 21000-21010 are not blocked by firewall
- Use explicit FTP (not SFTP)

### Services Keep Restarting
```bash
make fclean
make
```
This performs a clean rebuild.

---

## 9. Quick Reference

| Task | Command |
|------|---------|
| Start everything | `make` or `make up` |
| Stop everything | `make down` |
| View logs | `make logs` |
| Check status | `make status` |
| Full reset | `make fclean` |
| Rebuild from scratch | `make re` |
