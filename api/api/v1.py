from fastapi import FastAPI
from .routers import health, shared, workshop, minio, diagnostics

all_tags_metadata = [
    *health.tags_metadata,
    *shared.tags_metadata,
    *workshop.tags_metadata,
    *diagnostics.tags_metadata
]

api_v1 = FastAPI(
    title="AW4.0 Hub - API",
    version="1",
    openapi_tags=all_tags_metadata
)

api_v1.include_router(health.router, prefix="/health")
api_v1.include_router(shared.router, prefix="/shared")
api_v1.include_router(minio.router, prefix="/minio")
api_v1.include_router(workshop.router)
api_v1.include_router(diagnostics.router, prefix="/diagnostics")
