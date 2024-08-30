from datetime import datetime, timedelta

import httpx
import pytest
from api.data_management import (
    Customer
)
from api.routers import customers
from api.security.keycloak import Keycloak
from bson import ObjectId
from fastapi import FastAPI
from fastapi.testclient import TestClient
from jose import jws


@pytest.fixture
def jwt_payload():
    return {
        "iat": datetime.utcnow().timestamp(),
        "exp": (datetime.utcnow() + timedelta(60)).timestamp(),
        "preferred_username": "some-user-with-customers-access",
        "realm_access": {"roles": ["customers"]}
    }


@pytest.fixture
def signed_jwt(jwt_payload, rsa_private_key_pem: bytes):
    """Create a JWT signed with private RSA key."""
    return jws.sign(jwt_payload, rsa_private_key_pem, algorithm="RS256")


@pytest.fixture
def test_app(motor_db):
    test_app = FastAPI()
    test_app.include_router(customers.router)
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
def n_customers_in_data_context():
    return 3


@pytest.fixture
def customer_ids_in_data_context(n_customers_in_data_context):
    """Valid customer_id, e.g. needs to work with PydanticObjectId"""
    return [str(ObjectId()) for _ in range(n_customers_in_data_context)]


@pytest.fixture
def data_context(
        motor_db, customer_ids_in_data_context
):
    """
    Seed db with test data.

    Usage: `async with initialized_beanie_context, data_context: ...`
    """

    class DataContext:
        async def __aenter__(self):
            # Seed the db with a few customers
            for i, c_id in enumerate(customer_ids_in_data_context):
                await Customer(
                    id=c_id, first_name=f"F{i}", last_name=f"L{i}"
                ).create()

        async def __aexit__(self, exc_type, exc, tb):
            pass

    return DataContext()


@pytest.mark.asyncio
async def test_list_customers_in_empty_db(
        authenticated_async_client, initialized_beanie_context
):
    async with initialized_beanie_context:
        response = await authenticated_async_client.get("/")
    assert response.status_code == 200
    assert response.json() == []


@pytest.mark.asyncio
async def test_list_customers(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        n_customers_in_data_context
):
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get("/")
    assert response.status_code == 200
    assert len(response.json()) == n_customers_in_data_context


@pytest.mark.asyncio
async def test_add_customer(
        authenticated_async_client,
        initialized_beanie_context
):
    first_name = "some-first-name"
    last_name = "some-last-name"
    async with initialized_beanie_context:
        response = await authenticated_async_client.post(
            "/",
            json={"first_name": first_name, "last_name": last_name}
        )
        assert response.status_code == 201
        # Confirm customer data in response
        response_data = response.json()
        assert response_data["first_name"] == first_name
        assert response_data["last_name"] == last_name
        # Confirm storage in db
        customer_db = await Customer.get(response_data["_id"])
        assert customer_db.first_name == first_name
        assert customer_db.last_name == last_name


@pytest.mark.asyncio
async def test_get_customer(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        customer_ids_in_data_context
):
    customer_id = customer_ids_in_data_context[0]
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(f"/{customer_id}")
    assert response.status_code == 200
    assert response.json()["_id"] == customer_id


@pytest.mark.asyncio
async def test_update_customer(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        customer_ids_in_data_context
):
    customer_id = customer_ids_in_data_context[0]
    update = {"first_name": "NewFirstName", "city": "NewCity"}
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.patch(
            f"/{customer_id}", json=update
        )
        assert response.status_code == 200
        # Confirm customer data in response
        response_data = response.json()
        assert response_data["first_name"] == update["first_name"]
        assert response_data["city"] == update["city"]
        # Confirm storage in db
        customer_db = await Customer.get(response_data["_id"])
        assert customer_db.first_name == update["first_name"]
        assert customer_db.city == update["city"]


@pytest.mark.asyncio
async def test_delete_customer(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        customer_ids_in_data_context
):
    customer_id = customer_ids_in_data_context[0]
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.delete(f"/{customer_id}")
        assert response.status_code == 200
        assert response.json() is None
        # Confirm deletion in db
        customer_db = await Customer.get(customer_id)
        assert customer_db is None


@pytest.mark.parametrize("method", ["get", "patch", "delete"])
@pytest.mark.asyncio
async def test_customer_not_found(
        method,
        authenticated_async_client,
        initialized_beanie_context
):
    # Fresh ID and no data initialization
    customer_id = str(ObjectId())
    async with initialized_beanie_context:
        response = await authenticated_async_client.request(
            method=method, url=f"/{customer_id}"
        )
    assert response.status_code == 404
    assert response.json()["detail"] == \
           f"No customer with id '{customer_id}' found."


@pytest.mark.parametrize(
    "route", customers.router.routes, ids=lambda r: r.name
)
def test_missing_bearer_token(route, unauthenticated_client):
    """Endpoints should not be accessible without a bearer token."""
    assert len(route.methods) == 1, "Test assumes one method per route."
    method = next(iter(route.methods))
    response = unauthenticated_client.request(method=method, url=route.path)
    assert response.status_code == 403
    assert response.json() == {"detail": "Not authenticated"}


@pytest.fixture
def jwt_payload_with_unauthorized_role(jwt_payload):
    jwt_payload["realm_access"]["roles"] = ["workshop", "not customers"]
    return jwt_payload


@pytest.fixture
def signed_jwt_with_unauthorized_role(
        jwt_payload_with_unauthorized_role, rsa_private_key_pem: bytes
):
    return jws.sign(
        jwt_payload_with_unauthorized_role,
        rsa_private_key_pem, algorithm="RS256"
    )


@pytest.mark.parametrize(
    "route", customers.router.routes, ids=lambda r: r.name
)
def test_unauthorized_user(
        route, authenticated_client, signed_jwt_with_unauthorized_role
):
    """
    Endpoints should not be accessible, if the user role encoded in the
    token does not indicate customers access.
    """
    assert len(route.methods) == 1, "Test assumes one method per route."
    method = next(iter(route.methods))
    authenticated_client.headers.update(
        {"Authorization": f"Bearer {signed_jwt_with_unauthorized_role}"}
    )
    response = authenticated_client.request(method=method, url=route.path)
    assert response.status_code == 401
    assert response.json() == {"detail": "Could not validate token."}


@pytest.mark.parametrize(
    "route", customers.router.routes, ids=lambda r: r.name
)
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
        "realm_access": {"roles": ["customers"]}
    }


@pytest.fixture
def expired_jwt(expired_jwt_payload, rsa_private_key_pem: bytes):
    """Create an expired JWT signed with private RSA key."""
    return jws.sign(
        expired_jwt_payload, rsa_private_key_pem, algorithm="RS256"
    )


@pytest.mark.parametrize(
    "route", customers.router.routes, ids=lambda r: r.name
)
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
