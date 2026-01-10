FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Flask
RUN pip3 install flask

# Copy application files
COPY src/ /app/
COPY tools/start-website.sh /usr/local/bin/start-website.sh

RUN chmod +x /usr/local/bin/start-website.sh

WORKDIR /app

EXPOSE 5000

CMD ["/usr/local/bin/start-website.sh"]
