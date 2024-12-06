import logging

from fastapi import FastAPI

from .routers import (
    health, shared, workshop, diagnostics, knowledge,
    customers, assets
)
from .settings import settings


class EndpointLogFilter(logging.Filter):
    def __init__(self, prefix: str) -> None:
        self.prefix = prefix

    def filter(self, record: logging.LogRecord) -> bool:
        return record.getMessage().find(self.prefix) == -1


all_tags_metadata = [
    *health.tags_metadata,
    *shared.tags_metadata,
    *knowledge.tags_metadata,
    *workshop.tags_metadata,
    *diagnostics.tags_metadata,
    *customers.tags_metadata
]

api_v1 = FastAPI(
    title="AW4.0 Hub - API",
    version="1",
    openapi_tags=all_tags_metadata
)

api_v1.include_router(health.router, prefix="/health")
logging.getLogger("uvicorn.access").addFilter(EndpointLogFilter("/health"))

api_v1.include_router(shared.router, prefix="/shared")
api_v1.include_router(knowledge.router, prefix="/knowledge")
api_v1.include_router(workshop.router)
api_v1.include_router(customers.router, prefix="/customers")
# Prefixes for the assets routers are handled in the module
api_v1.include_router(assets.management_router)
api_v1.include_router(assets.public_router)
if not settings.exclude_diagnostics_router:
    api_v1.include_router(diagnostics.router, prefix="/diagnostics")
else:
    print("Router /diagnostics is excluded.")
