from datetime import datetime, timedelta

import httpx
import pytest
from api.data_management import (
    Case, NewTimeseriesData, TimeseriesMetaData, GridFSSignalStore, NewOBDData,
    NewSymptom
)
from api.diagnostics_management import KnowledgeGraph
from api.routers import shared
from api.security.keycloak import Keycloak
from bson import ObjectId
from fastapi import FastAPI
from fastapi.testclient import TestClient
from jose import jws
from motor import motor_asyncio


@pytest.fixture
def jwt_payload():
    return {
        "iat": datetime.utcnow().timestamp(),
        "exp": (datetime.utcnow() + timedelta(60)).timestamp(),
        "preferred_username": "some-user-with-shared-access",
        "realm_access": {"roles": ["shared"]}
    }


@pytest.fixture
def signed_jwt(jwt_payload, rsa_private_key_pem: bytes):
    """Create a JWT signed with private RSA key."""
    return jws.sign(jwt_payload, rsa_private_key_pem, algorithm="RS256")


@pytest.fixture
def test_app(motor_db):
    test_app = FastAPI()
    test_app.include_router(shared.router)
    yield test_app


@pytest.fixture
def unauthenticated_client(test_app):
    """Unauthenticated client, e.g. no bearer token in header."""
    yield TestClient(test_app)


@pytest.fixture
def authenticated_client(
        unauthenticated_client, rsa_public_key_pem, signed_jwt
):
    """Turn unauthenticated client into authenticated client."""

    # Client gets auth header with valid bearer token
    client = unauthenticated_client
    client.headers.update({"Authorization": f"Bearer {signed_jwt}"})

    # Make app use public key from fixture for token validation
    app = client.app
    app.dependency_overrides[
        Keycloak.get_public_key_for_workshop_realm
    ] = lambda: rsa_public_key_pem.decode()

    return client


@pytest.fixture
def authenticated_async_client(
        test_app, rsa_public_key_pem, signed_jwt
):
    """
    Authenticated async client for tests that require mongodb access via beanie
    """

    # Client with valid auth header
    client = httpx.AsyncClient(
        app=test_app,
        base_url="http://",
        headers={"Authorization": f"Bearer {signed_jwt}"}
    )

    # Make app use public key from fixture for token validation
    test_app.dependency_overrides[
        Keycloak.get_public_key_for_workshop_realm
    ] = lambda: rsa_public_key_pem.decode()

    return client


@pytest.fixture
def case_id():
    """Valid case_id, e.g. needs to work with PydanticObjectId"""
    return str(ObjectId())


@pytest.fixture
def case_data(case_id):
    """Valid minimal case data."""
    return {
        "_id": case_id,
        "vehicle_vin": "test-vin",
        "workshop_id": "test-workshop-id",
    }


@pytest.fixture
def timeseries_data():
    return {
        "component": "battery",
        "label": "norm",
        "sampling_rate": 1,
        "duration": 3,
        "type": "oscillogram",
        "signal": [0., 1., 2.]
    }


@pytest.fixture
def obd_data():
    return {
        "dtcs": ["P0001", "U0001"]
    }


@pytest.fixture
def symptom_data():
    return {
        "component": "battery",
        "label": "defect"
    }


@pytest.fixture
def data_context(motor_db, case_data, timeseries_data, obd_data, symptom_data):
    """
    Seed db with test data.

    Usage: `async with initialized_beanie_context, data_context: ...`
    """
    # Configure the GridFS signal store to allow timeseries data CRUD
    bucket = motor_asyncio.AsyncIOMotorGridFSBucket(
        motor_db, bucket_name="test-signals"
    )
    TimeseriesMetaData.signal_store = GridFSSignalStore(bucket=bucket)

    class DataContext:
        async def __aenter__(self):
            # Seed the db with a case
            case = Case(**case_data)
            await case.create()
            # Add timeseries data to the case
            await case.add_timeseries_data(
                NewTimeseriesData(**timeseries_data)
            )
            # Add obd data to the case
            await case.add_obd_data(
                NewOBDData(**obd_data)
            )
            # Add symptom to the case
            await case.add_symptom(
                NewSymptom(**symptom_data)
            )

        async def __aexit__(self, exc_type, exc, tb):
            pass

    # Yield context instance to the test function
    yield DataContext()
    # Reset timeseries signal store after test
    TimeseriesMetaData.signal_store = None
    # Drop signal collections from test database
    signal_files = motor_db[
        bucket.collection.name + ".files"
        ]
    signal_chunks = motor_db[
        bucket.collection.name + ".chunks"
        ]
    signal_files.drop()
    signal_files.drop_indexes()
    signal_chunks.drop()
    signal_chunks.drop_indexes()


def test_get_case_invalid_id(authenticated_client):
    # Invalid case_id format is passed
    response = authenticated_client.get("/cases/invalidid")
    assert response.status_code == 404
    assert "detail" in response.json()


@pytest.mark.asyncio
async def test_get_case_non_existent(
        authenticated_async_client, case_id, initialized_beanie_context
):
    async with initialized_beanie_context:
        # Try to get case from an empty db
        response = await authenticated_async_client.get(f"/cases/{case_id}")

    assert response.status_code == 404


@pytest.mark.asyncio
async def test_get_case(
        authenticated_async_client, case_data, case_id,
        initialized_beanie_context
):
    async with initialized_beanie_context:
        # Seed db with a case and try to get it
        await Case(**case_data).create()
        response = await authenticated_async_client.get(f"/cases/{case_id}")

    assert response.status_code == 200
    assert response.json()["_id"] == case_id


@pytest.mark.asyncio
async def test_list_timeseries_data(
        authenticated_async_client, case_id, timeseries_data,
        initialized_beanie_context, data_context
):
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(
            f"/cases/{case_id}/timeseries_data"
        )

    assert response.status_code == 200
    response_data = response.json()
    assert len(response_data) == 1
    assert response_data[0]["sampling_rate"] == \
           timeseries_data["sampling_rate"]


@pytest.mark.asyncio
async def test_get_timeseries_data(
        authenticated_async_client, case_id, timeseries_data,
        initialized_beanie_context, data_context
):
    data_id = 0  # id in data_context
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(
            f"/cases/{case_id}/timeseries_data/{data_id}"
        )

    assert response.status_code == 200
    response_data = response.json()
    assert response_data["sampling_rate"] == \
           timeseries_data["sampling_rate"]
    assert response_data["data_id"] == data_id


@pytest.mark.asyncio
async def test_get_timeseries_data_not_found(
        authenticated_async_client, case_id, timeseries_data,
        initialized_beanie_context, data_context
):
    data_id = 1  # id not in data_context
    expected_exception_detail = f"No timeseries_data with data_id " \
                                f"`{data_id}` in case {case_id}."

    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(
            f"/cases/{case_id}/timeseries_data/{data_id}"
        )

    assert response.status_code == 404
    assert response.json()["detail"] == expected_exception_detail


@pytest.mark.asyncio
async def test_get_timeseries_data_signal(
        authenticated_async_client, case_id, timeseries_data,
        initialized_beanie_context, data_context
):
    data_id = 0  # id in data_context
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(
            f"/cases/{case_id}/timeseries_data/{data_id}/signal"
        )

    assert response.status_code == 200
    assert response.json() == timeseries_data["signal"]


@pytest.mark.asyncio
async def test_get_timeseries_data_signal_not_found(
        authenticated_async_client, case_id, timeseries_data,
        initialized_beanie_context, data_context
):
    data_id = 1  # id not in data_context
    expected_exception_detail = f"No timeseries_data with data_id " \
                                f"`{data_id}` in case {case_id}."

    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(
            f"/cases/{case_id}/timeseries_data/{data_id}/signal"
        )

    assert response.status_code == 404
    assert response.json()["detail"] == expected_exception_detail


@pytest.mark.asyncio
async def test_list_obd_data(
        authenticated_async_client, case_id, obd_data,
        initialized_beanie_context, data_context
):
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(
            f"/cases/{case_id}/obd_data"
        )

    assert response.status_code == 200
    response_data = response.json()
    assert len(response_data) == 1
    assert response_data[0]["dtcs"] == obd_data["dtcs"]


@pytest.mark.asyncio
async def test_get_obd_data(
        authenticated_async_client, case_id, obd_data,
        initialized_beanie_context, data_context
):
    data_id = 0  # id in data_context
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(
            f"/cases/{case_id}/obd_data/{data_id}"
        )

    assert response.status_code == 200
    response_data = response.json()
    assert response_data["dtcs"] == obd_data["dtcs"]
    assert response_data["data_id"] == data_id


@pytest.mark.asyncio
async def test_get_obd_data_not_found(
        authenticated_async_client, case_id, obd_data,
        initialized_beanie_context, data_context
):
    data_id = 1  # id not in data_context
    expected_exception_detail = f"No obd_data with data_id " \
                                f"`{data_id}` in case {case_id}."

    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(
            f"/cases/{case_id}/obd_data/{data_id}"
        )

    assert response.status_code == 404
    assert response.json()["detail"] == expected_exception_detail


@pytest.mark.asyncio
async def test_list_symptoms(
        authenticated_async_client, case_id, symptom_data,
        initialized_beanie_context, data_context
):
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(
            f"/cases/{case_id}/symptoms"
        )

    assert response.status_code == 200
    response_data = response.json()
    assert len(response_data) == 1
    assert response_data[0]["label"] == symptom_data["label"]


@pytest.mark.asyncio
async def test_get_symptom(
        authenticated_async_client, case_id, symptom_data,
        initialized_beanie_context, data_context
):
    data_id = 0  # id in data_context
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(
            f"/cases/{case_id}/symptoms/{data_id}"
        )

    assert response.status_code == 200
    response_data = response.json()
    assert response_data["label"] == symptom_data["label"]
    assert response_data["data_id"] == data_id


@pytest.mark.asyncio
async def test_get_symptom_not_found(
        authenticated_async_client, case_id, symptom_data,
        initialized_beanie_context, data_context
):
    data_id = 1  # id not in data_context
    expected_exception_detail = f"No symptom with data_id " \
                                f"`{data_id}` in case {case_id}."

    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(
            f"/cases/{case_id}/symptoms/{data_id}"
        )

    assert response.status_code == 404
    assert response.json()["detail"] == expected_exception_detail


def test_list_vehicle_components_no_kg_configured(authenticated_client):
    KnowledgeGraph.set_kg_url(None)
    response = authenticated_client.get("/known-components")
    assert response.status_code == 200
    assert response.json() == []


def test_list_vehicle_components_kg_not_available(authenticated_client):
    KnowledgeGraph.set_kg_url("http://no-kg-hosted-here:4242")
    response = authenticated_client.get("/known-components")
    assert response.status_code == 200
    assert response.json() == []


@pytest.fixture
def kg_url():
    """Assume local fuseki server is available at 3030"""
    return "http://127.0.0.1:3030"


@pytest.fixture()
def obd_dataset_name():
    return "OBDpytest"


@pytest.fixture
def prefilled_knowledge_graph(
        kg_url, obd_dataset_name, knowledge_graph_file
):
    # create a fresh dataset for testing
    httpx.post(
        url=f"{kg_url}/$/datasets",
        data={
            "dbType": "mem",
            "dbName": f"/{obd_dataset_name}",
        }
    )
    # load content from knowledge_graph_file fixture into the test dataset
    httpx.put(
        url=f"{kg_url}/{obd_dataset_name}",
        content=knowledge_graph_file,
        headers={"Content-Type": "text/turtle"}
    )
    yield
    # remove the dataset after testing
    httpx.delete(url=f"{kg_url}/$/datasets/{obd_dataset_name}")


def test_list_vehicle_components(
        authenticated_client, kg_url, obd_dataset_name,
        prefilled_knowledge_graph
):
    # point the endpoint dependency to the test dataset
    KnowledgeGraph.set_kg_url(kg_url)
    KnowledgeGraph.obd_dataset_name = obd_dataset_name
    # test
    response = authenticated_client.get("/known-components")
    assert response.status_code == 200
    assert response.json() == [
        "boost_pressure_control_valve", "boost_pressure_solenoid_valve"
    ]


@pytest.mark.parametrize("route", shared.router.routes, ids=lambda r: r.name)
def test_missing_bearer_token(route, unauthenticated_client):
    """Endpoints should not be accessible without a bearer token."""
    assert len(route.methods) == 1, "Test assumes one method per route."
    method = next(iter(route.methods))
    response = unauthenticated_client.request(method=method, url=route.path)
    assert response.status_code == 403
    assert response.json() == {"detail": "Not authenticated"}


@pytest.fixture
def jwt_payload_with_unauthorized_role(jwt_payload):
    jwt_payload["realm_access"]["roles"] = ["workshop", "not shared"]
    return jwt_payload


@pytest.fixture
def signed_jwt_with_unauthorized_role(
        jwt_payload_with_unauthorized_role, rsa_private_key_pem: bytes
):
    return jws.sign(
        jwt_payload_with_unauthorized_role,
        rsa_private_key_pem, algorithm="RS256"
    )


@pytest.mark.parametrize("route", shared.router.routes, ids=lambda r: r.name)
def test_unauthorized_user(
        route, authenticated_client, signed_jwt_with_unauthorized_role
):
    """
    Endpoints should not be accessible, if the user role encoded in the
    token does not indicate shared access.
    """
    assert len(route.methods) == 1, "Test assumes one method per route."
    method = next(iter(route.methods))
    authenticated_client.headers.update(
        {"Authorization": f"Bearer {signed_jwt_with_unauthorized_role}"}
    )
    response = authenticated_client.request(method=method, url=route.path)
    assert response.status_code == 401
    assert response.json() == {"detail": "Could not validate token."}


@pytest.mark.parametrize("route", shared.router.routes, ids=lambda r: r.name)
def test_invalid_jwt_signature(
        route, authenticated_client, another_rsa_public_key_pem
):
    """
    Endpoints should not be accessible, if the public key retrieved from
    keycloak does not match the private key used to sign a JWT.
    """
    assert len(route.methods) == 1, "Test assumes one method per route."
    method = next(iter(route.methods))
    # The token signature of the authenticated client will not match the public
    #  key anymore
    authenticated_client.app.dependency_overrides[
        Keycloak.get_public_key_for_workshop_realm
    ] = lambda: another_rsa_public_key_pem.decode()
    response = authenticated_client.request(method=method, url=route.path)
    assert response.status_code == 401
    assert response.json() == {"detail": "Could not validate token."}


@pytest.fixture
def expired_jwt_payload():
    return {
        "iat": (datetime.utcnow() - timedelta(60)).timestamp(),
        "exp": (datetime.utcnow() - timedelta(1)).timestamp(),
        "preferred_username": "user",
        "realm_access": {"roles": ["shared"]}
    }


@pytest.fixture
def expired_jwt(expired_jwt_payload, rsa_private_key_pem: bytes):
    """Create an expired JWT signed with private RSA key."""
    return jws.sign(
        expired_jwt_payload, rsa_private_key_pem, algorithm="RS256"
    )


@pytest.mark.parametrize("route", shared.router.routes, ids=lambda r: r.name)
def test_expired_jwt(route, authenticated_client, expired_jwt):
    """
    Endpoints should not be accessible, if the bearer token is expired.
    """
    assert len(route.methods) == 1, "Test assumes one method per route."
    method = next(iter(route.methods))
    # The token offered by the authenticated client is expired
    response = authenticated_client.request(
        method=method,
        url=route.path,
        headers={"Authorization": f"Bearer {expired_jwt}"}
    )
    assert response.status_code == 401
    assert response.json() == {"detail": "Could not validate token."}
