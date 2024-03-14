# syntax=docker/dockerfile:1.7.0
FROM mongo:6.0.2

# init-users will create a non-root db user for the api on mongo startup
COPY ./init-users.sh /docker-entrypoint-initdb.d

# Check if port 27017 (hex 0x6989) is open before calling mongosh check
# Syntax: <local ipv4 hex>:<local port hex> <remote ipv4 hex>:<remote port hex>
# for local port listening on all interfaces:
# 00000000:<local port hex> 00000000:0000
# Source: https://www.kernel.org/doc/Documentation/networking/proc_net_tcp.txt
HEALTHCHECK --start-period=30s --start-interval=1s --interval=30s --timeout=5s --retries=5 \
  CMD grep -q '00000000:6989 00000000:0000' /proc/net/tcp && \
      mongosh --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)'
