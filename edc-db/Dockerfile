FROM postgres:15-alpine

HEALTHCHECK --interval=30s --timeout=2s --retries=5 \
  CMD pg_isready -q -d $POSTGRES_USER -U $POSTGRES_USER || exit 1
