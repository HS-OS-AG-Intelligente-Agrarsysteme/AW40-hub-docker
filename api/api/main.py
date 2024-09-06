from beanie import init_beanie
from celery import Celery
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from motor import motor_asyncio

from .data_management import (
    Case, Vehicle, Customer, Workshop, TimeseriesMetaData, Diagnosis,
    AttachmentBucket
)
from .data_management.timeseries_data import GridFSSignalStore
from .diagnostics_management import DiagnosticTaskManager, KnowledgeGraph
from .settings import settings
from .storage.storage_factory import StorageFactory
from .security.keycloak import Keycloak
from .v1 import api_v1
from .routers import diagnostics
from .routers import minio

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allow_headers=["*"],
)


@app.middleware("http")
async def add_strict_transport_security(request: Request, call_next):
    response = await call_next(request)
    response.headers["Strict-Transport-Security"] = \
        "max-age=31536000; includeSubDomains"
    return response


app.mount("/v1", api_v1)


@app.on_event("startup")
async def init_mongo():
    # initialize beanie
    client = motor_asyncio.AsyncIOMotorClient(settings.mongo_uri)
    await init_beanie(
        client[settings.mongo_db],
        document_models=[
            Case, Vehicle, Customer, Workshop, Diagnosis
        ]
    )

    # initialized gridfs signal storage
    bucket = motor_asyncio.AsyncIOMotorGridFSBucket(
        client[settings.mongo_db], bucket_name="signals"
    )
    TimeseriesMetaData.signal_store = GridFSSignalStore(bucket=bucket)

    # initialized attachment store for diagnostics api
    AttachmentBucket.bucket = motor_asyncio.AsyncIOMotorGridFSBucket(
        client[settings.mongo_db], bucket_name="attachments"
    )


@app.on_event("startup")
async def init_diagnostics_management():
    DiagnosticTaskManager.set_celery(
        Celery(
            broker=settings.redis_uri, backend=settings.redis_uri
        )
    )


@app.on_event("startup")
def init_storages():
    StorageFactory.initialise_storages(
        minio_host=settings.minio_api_address,
        minio_password=settings.minio_password,
        minio_username=settings.minio_username,
        minio_use_tls=settings.minio_use_tls,
        minio_check_cert=settings.minio_check_cert
    )


@app.on_event("startup")
def init_knowledge_graph():
    KnowledgeGraph.set_kg_url(settings.knowledge_graph_url)


@app.on_event("startup")
def init_keycloak():
    Keycloak.configure(
        url=settings.keycloak_url,
        workshop_realm=settings.keycloak_workshop_realm
    )


@app.on_event("startup")
def set_api_keys():
    diagnostics.api_key_auth.valid_key = settings.api_key_diagnostics
    minio.api_key_auth.valid_key = settings.api_key_minio
