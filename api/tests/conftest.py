import inspect
import os
import sys

import httpx
import pytest
from api.data_management import (
    Case,
    Vehicle,
    Customer,
    Workshop,
    Diagnosis
)
from beanie import init_beanie
from bson import ObjectId
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from motor import motor_asyncio


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
        Case, Vehicle, Customer, Workshop, Diagnosis
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
def omniview_csv_file(files_dir):
    path = os.path.join(files_dir, "omniview.csv")
    f = open(path, "rb")
    yield f
    f.close()


@pytest.fixture
def omniview_sin_csv_file(files_dir):
    """Test file with sin wave including negative and zero data points."""
    path = os.path.join(files_dir, "omniview_sin.csv")
    f = open(path, "rb")
    yield f
    f.close()


@pytest.fixture
def kg_url():
    """Assume local knowledge graph is available at 3030"""
    return "http://127.0.0.1:3030"


@pytest.fixture()
def kg_obd_dataset_name():
    """
    Dedicated knowledge graph dataset name for testing to avoid interference
    with any real datasets.
    """
    return "OBDpytest"


@pytest.fixture
def kg_file(files_dir):
    """
    Knowledge graph data to put into test instance.

    This file currently has two components defined:
    - "boost_pressure_solenoid_valve"
    - "boost_pressure_control_valve"
    Note that they are available via the kg_components fixture
    """
    path = os.path.join(files_dir, "minimalistic_kg.ttl")
    f = open(path, "rb")
    yield f
    f.close()


@pytest.fixture
def kg_components():
    """The components present in the test knowledge graph data."""
    return ["boost_pressure_solenoid_valve", "boost_pressure_control_valve"]


@pytest.fixture
def kg_prefilled(
        kg_url, kg_obd_dataset_name, kg_file
):
    """Prefill the local knowledge graph for testing."""
    # create a fresh dataset for testing
    httpx.post(
        url=f"{kg_url}/$/datasets",
        data={
            "dbType": "mem",
            "dbName": f"/{kg_obd_dataset_name}",
        }
    )
    # load content from knowledge_graph_file fixture into the test dataset
    httpx.put(
        url=f"{kg_url}/{kg_obd_dataset_name}",
        content=kg_file,
        headers={"Content-Type": "text/turtle"}
    )
    yield
    # remove the dataset after testing
    httpx.delete(url=f"{kg_url}/$/datasets/{kg_obd_dataset_name}")


def _create_rsa_key_pair() -> tuple[bytes, bytes]:
    private_key = rsa.generate_private_key(
        public_exponent=65537, key_size=2048
    )
    private_key_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=serialization.NoEncryption()
    )
    public_key_pem = private_key.public_key().public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    return private_key_pem, public_key_pem


@pytest.fixture
def rsa_key_pair() -> tuple[bytes, bytes]:
    """Create RSA private and public key in PEM format."""
    return _create_rsa_key_pair()


@pytest.fixture
def rsa_private_key_pem(rsa_key_pair) -> bytes:
    return rsa_key_pair[0]


@pytest.fixture
def rsa_public_key_pem(rsa_key_pair) -> bytes:
    return rsa_key_pair[1]


@pytest.fixture
def another_rsa_public_key_pem() -> bytes:
    """Get a public key that does not match keys from any other fixture."""
    _, public_key_pem = _create_rsa_key_pair()
    return public_key_pem
