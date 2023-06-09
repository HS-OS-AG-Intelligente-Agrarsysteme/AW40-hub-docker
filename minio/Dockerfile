ARG MINIO_VER
FROM quay.io/minio/minio:$MINIO_VER

# might get filled later on
HEALTHCHECK --interval=30s --timeout=2s --retries=5 \
  CMD curl -fs http://localhost:9000/minio/health/live || exit 1