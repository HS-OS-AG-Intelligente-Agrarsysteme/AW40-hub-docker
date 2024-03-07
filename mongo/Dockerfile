FROM mongo:6.0.2

# init-users will create a non-root db user for the api on mongo startup
COPY ./init-users.sh /docker-entrypoint-initdb.d

HEALTHCHECK --start-period=30s --start-interval=1s --interval=30s --timeout=2s --retries=5 \
  CMD mongosh --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)'
  