from beanie import init_beanie
from celery import Celery
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from motor import motor_asyncio

from .data_management import (
    Case, Vehicle, Customer, Workshop, TimeseriesMetaData, DiagnosisDB, Action,
    ToDo, AttachmentBucket
)
from .data_management.timeseries_data import GridFSSignalStore
from .diagnostics_management import DiagnosticTaskManager
from .settings import settings
from .utils import create_action_data
from .v1 import api_v1
from .demo_ui import ui

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allow_headers=["*"],
)
app.mount("/v1", api_v1)

app.mount("/ui", ui.app)


@app.on_event("startup")
async def init_mongo():

    # initialize beanie
    client = motor_asyncio.AsyncIOMotorClient(settings.mongo_uri)
    await init_beanie(
        client[settings.mongo_db],
        document_models=[
            Case, Vehicle, Customer, Workshop, DiagnosisDB, Action, ToDo
        ]
    )

    # initialized gridfs signal storage
    bucket = motor_asyncio.AsyncIOMotorGridFSBucket(
        client[settings.mongo_db], bucket_name="signals"
    )
    TimeseriesMetaData.signal_store = GridFSSignalStore(bucket=bucket)

    # prefill the 'actions' collection on startup
    for data in create_action_data():
        action = Action(**data)
        await action.save()

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
