from datetime import datetime, timedelta

import httpx
import pytest
from api.diagnostics_management import KnowledgeGraph
from api.routers import shared
from api.security.keycloak import Keycloak
from fastapi import FastAPI
from fastapi.testclient import TestClient
from jose import jws


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
def test_app():
    app = FastAPI()
    app.include_router(shared.router)
    return app


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
