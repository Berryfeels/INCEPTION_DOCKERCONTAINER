#!/bin/bash

# Read password from secret
REDIS_PASSWORD=$(cat /run/secrets/redis_password)

# Start redis with password
exec redis-server /etc/redis/redis.conf --requirepass "${REDIS_PASSWORD}"