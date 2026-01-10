FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y redis-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy Redis configuration
COPY conf/redis.conf /etc/redis/redis.conf

RUN chown redis:redis /etc/redis/redis.conf

EXPOSE 6379

USER redis

CMD ["redis-server", "/etc/redis/redis.conf"]
