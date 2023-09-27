from . import minio_storage

SUPPORTED_STORAGES = {
    "MinIO": minio_storage.MinIOStorage,
}
