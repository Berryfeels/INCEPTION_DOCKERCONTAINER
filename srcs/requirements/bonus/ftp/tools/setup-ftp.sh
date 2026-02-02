#!/bin/bash

# Read password from secret
FTP_PASSWORD=$(cat /run/secrets/ftp_password)

# Create FTP user
adduser --disabled-password --gecos "" ftpuser
echo "ftpuser:ftppass" | chpasswd

# Add user to allowed list
echo "ftpuser" > /etc/vsftpd.userlist

# Set permissions for WordPress files
chown -R ftpuser:ftpuser /var/www/html
chmod -R 755 /var/www/html

echo "FTP server starting..."
exec vsftpd /etc/vsftpd.conf
