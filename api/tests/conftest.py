import inspect
import os
import sys

import pytest
from api.data_management import (
    Case,
    Vehicle,
    Customer,
    Workshop,
    DiagnosisDB,
    Action,
    ToDo
)
from bson import ObjectId
from motor import motor_asyncio
from beanie import init_beanie


@pytest.fixture
def motor_client():
    """
    Assume a local mongodb instance is available with credentials as in dev.env
    """
    mongo_uri = "mongodb://mongo-api-user:mongo-api-pw@127.0.0.1:27017/" \
                "?authSource=admin"
    return motor_asyncio.AsyncIOMotorClient(mongo_uri)


@pytest.fixture
def motor_db(motor_client):
    """
    Use database 'aw40-hub-test'. Database 'aw40-hub' ist defined in dev.env
    and hence mongo/init-users.sh should have created readWrite role for
    api user.
    """
    yield motor_client["aw40-hub-test"]


@pytest.fixture
def initialized_beanie_context(motor_db):
    """
    Could not get standard pytest fixture setup and teardown to work for
    beanie initialization. As a workaround this fixture creates an async
    context manager to handle test setup and teardown.
    """
    models = [
        Case, Vehicle, Customer, Workshop, DiagnosisDB, Action, ToDo
    ]

    class InitializedBeanieContext:
        async def __aenter__(self):
            await init_beanie(
                motor_db,
                document_models=models
            )
            for model in models:
                # make sure all collections are empty at the beginning of each
                # test
                await model.delete_all()

        async def __aexit__(self, exc_type, exc, tb):
            for model in models:
                # drop all collections and indexes after each test
                await model.get_motor_collection().drop()
                await model.get_motor_collection().drop_indexes()

    return InitializedBeanieContext()


@pytest.fixture
def signal_bucket(motor_db):
    test_bucket_name = "signals-pytest"  # dedicated test bucket
    test_bucket = motor_asyncio.AsyncIOMotorGridFSBucket(
        motor_db, bucket_name=test_bucket_name
    )
    yield test_bucket

    # teardown by dropping the test bucket gridfs collections
    motor_db.drop_collection(f"{test_bucket_name}.files")
    motor_db.drop_collection(f"{test_bucket_name}.chunks")


@pytest.fixture
def timeseries_meta_data():
    """Valid timeseries meta data"""
    return {
        "component": "battery",
        "label": "unknown",
        "sampling_rate": 1,
        "duration": 3,
        "type": "oscillogram"
    }


@pytest.fixture
def timeseries_signal_id():
    """Valid timeseries signal id, e.g. needs to work with PydanticObjectId"""
    return str(ObjectId())


@pytest.fixture
def timeseries_data(timeseries_meta_data, timeseries_signal_id):
    """Data expected to validate successfully with TimeseriesData"""
    timeseries_meta_data["signal_id"] = timeseries_signal_id
    return timeseries_meta_data


@pytest.fixture
def timeseries_signal():
    return [-1.0, 0, 1.0]


@pytest.fixture
def new_timeseries_data(timeseries_meta_data, timeseries_signal):
    """Data expected to validate successfully with NewTimeseriesData"""
    timeseries_meta_data["signal"] = timeseries_signal
    return timeseries_meta_data


@pytest.fixture
def files_dir():
    main_test_dir = os.path.dirname(
        inspect.getfile(
            sys.modules[__name__]
        )
    )
    return os.path.join(main_test_dir, "files")


@pytest.fixture
def picoscope_1ch_mat_file(files_dir):
    path = os.path.join(files_dir, "picoscope_1ch.mat")
    f = open(path, "rb")
    yield f
    f.close()


@pytest.fixture
def picoscope_4ch_mat_file(files_dir):
    path = os.path.join(files_dir, "picoscope_4ch.mat")
    f = open(path, "rb")
    yield f
    f.close()


@pytest.fixture
def picoscope_1ch_eng_csv_file(files_dir):
    path = os.path.join(files_dir, "picoscope_1ch_eng.csv")
    f = open(path, "rb")
    yield f
    f.close()


@pytest.fixture
def picoscope_4ch_eng_csv_file(files_dir):
    path = os.path.join(files_dir, "picoscope_4ch_eng.csv")
    f = open(path, "rb")
    yield f
    f.close()


@pytest.fixture
def picoscope_1ch_ger_csv_file(files_dir):
    path = os.path.join(files_dir, "picoscope_1ch_ger.csv")
    f = open(path, "rb")
    yield f
    f.close()


@pytest.fixture
def picoscope_4ch_ger_csv_file(files_dir):
    path = os.path.join(files_dir, "picoscope_4ch_ger.csv")
    f = open(path, "rb")
    yield f
    f.close()


@pytest.fixture
def picoscope_8ch_ger_comma_decimal_csv_file(files_dir):
    path = os.path.join(files_dir, "picoscope_8ch_ger_comma_decimal.csv")
    f = open(path, "rb")
    yield f
    f.close()


@pytest.fixture
def vcds_txt_file(files_dir):
    path = os.path.join(files_dir, "vcds.txt")
    f = open(path, "rb")
    yield f
    f.close()


@pytest.fixture
def vcds_no_milage_txt_file(files_dir):
    path = os.path.join(files_dir, "vcds_no_milage.txt")
    f = open(path, "rb")
    yield f
    f.close()


@pytest.fixture
def omniscope_v1_file(files_dir):
    path = os.path.join(files_dir, "omniscope")
    f = open(path, "rb")
    yield f
    f.close()
