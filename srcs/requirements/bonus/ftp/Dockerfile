FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y vsftpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy FTP configuration
COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/setup-ftp.sh /usr/local/bin/setup-ftp.sh

RUN chmod +x /usr/local/bin/setup-ftp.sh

# Create FTP directories
RUN mkdir -p /var/run/vsftpd/empty && \
    mkdir -p /var/ftp && \
    chmod 755 /var/ftp

EXPOSE 21 20 21000-21010

CMD ["/usr/local/bin/setup-ftp.sh"]
