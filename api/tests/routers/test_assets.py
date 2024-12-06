import os
from datetime import datetime, timedelta, UTC
from unittest.mock import AsyncMock
from zipfile import ZipFile

import httpx
import pytest
from api.data_management import (
    Asset, AssetDefinition, Publication
)
from api.dataspace_management import nautilus
from api.routers import assets
from api.routers.assets import Nautilus
from api.security.keycloak import Keycloak
from bson import ObjectId
from fastapi import FastAPI
from fastapi.testclient import TestClient
from jose import jws


@pytest.fixture
def jwt_payload():
    return {
        "iat": datetime.now(UTC).timestamp(),
        "exp": (datetime.now(UTC) + timedelta(60)).timestamp(),
        "preferred_username": "some-user-with-assets-access",
        "realm_access": {"roles": ["assets"]}
    }


@pytest.fixture
def signed_jwt(jwt_payload, rsa_private_key_pem: bytes):
    """Create a JWT signed with private RSA key."""
    return jws.sign(jwt_payload, rsa_private_key_pem, algorithm="RS256")


@pytest.fixture
def app(motor_db):
    app = FastAPI()
    app.include_router(assets.management_router)
    app.include_router(assets.public_router)
    assets.api_key_auth.valid_key = "assets-key-dev"
    yield app


@pytest.fixture
def unauthenticated_client(app):
    """Unauthenticated client, e.g. no bearer token in header."""
    yield TestClient(app)


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
def base_url():
    return "http://testserver"


@pytest.fixture
def authenticated_async_client(
        app, rsa_public_key_pem, signed_jwt, base_url
):
    """
    Authenticated async client for tests that require mongodb access via
    beanie. Note that for this module, this is the client authorized to
    manage assets via /dataspace/manage/...
    """

    # Client with valid auth header
    client = httpx.AsyncClient(
        transport=httpx.ASGITransport(app=app),
        base_url=base_url,
        headers={"Authorization": f"Bearer {signed_jwt}"}
    )

    # Make app use public key from fixture for token validation
    app.dependency_overrides[
        Keycloak.get_public_key_for_workshop_realm
    ] = lambda: rsa_public_key_pem.decode()

    return client


@pytest.fixture
def n_assets_in_data_context():
    return 2


@pytest.fixture
def asset_ids_in_data_context(n_assets_in_data_context):
    """Valid asset_id, e.g. needs to work with PydanticObjectId"""
    return [str(ObjectId()) for _ in range(n_assets_in_data_context)]


@pytest.fixture
def data_context(
        motor_db, asset_ids_in_data_context
):
    """
    Seed db with test data.

    Usage: `async with initialized_beanie_context, data_context: ...`
    """

    class DataContext:
        async def __aenter__(self):
            # Seed the db with a few assets
            for i, a_id in enumerate(asset_ids_in_data_context):
                await Asset(
                    id=a_id,
                    name=f"A{i}",
                    description=f"This is asset {i}.",
                    definition=AssetDefinition(),
                    author="Test author"
                ).create()

        async def __aexit__(self, exc_type, exc, tb):
            pass

    return DataContext()


@pytest.mark.asyncio
async def test_list_assets_in_empty_db(
        authenticated_async_client, initialized_beanie_context
):
    async with initialized_beanie_context:
        response = await authenticated_async_client.get(
            "/dataspace/manage/assets"
        )
    assert response.status_code == 200
    assert response.json() == []


@pytest.mark.asyncio
async def test_list_assets(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        n_assets_in_data_context
):
    async with initialized_beanie_context, data_context:
        # Request without any additional params
        response = await authenticated_async_client.get(
            "/dataspace/manage/assets"
        )
    # Validate response status code and data
    assert response.status_code == 200
    assert len(response.json()) == n_assets_in_data_context


@pytest.mark.asyncio
async def test_add_asset(
        authenticated_async_client,
        initialized_beanie_context
):
    name = "New Asset"
    description = "A new asset added via the api."
    async with initialized_beanie_context:
        response = await authenticated_async_client.post(
            "/dataspace/manage/assets",
            json={
                "name": name,
                "description": description,
                "definition": {},
                "author": "Test author"
            }
        )
        assert response.status_code == 201
        # Confirm asset data in response
        response_data = response.json()
        assert response_data["name"] == name
        assert response_data["description"] == description
        assert response_data["data_status"] == "defined"
        # Confirm storage in db
        asset_db = await Asset.get(response_data["_id"])
        assert asset_db
        assert asset_db.name == name
        assert asset_db.description == description
        # Confirm processing of the asset
        assert asset_db.data_status == "ready"
        assert os.path.exists(asset_db.data_file_path)


@pytest.mark.asyncio
async def test_get_asset(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context
):
    asset_id = asset_ids_in_data_context[0]
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.get(
            f"/dataspace/manage/assets/{asset_id}"
        )
    assert response.status_code == 200
    assert response.json()["_id"] == asset_id


@pytest.fixture
def patch_nautilus_to_fail_revocation(
        authenticated_async_client, monkeypatch
):
    """
    Patch Nautilus to enforce failure of any attempt to revoke a publication
    in the dataspace.
    """
    # Configure url to avoid failure of Nautilus constructor
    Nautilus.configure(
        url="http://nothing-here",
        timeout=None,
        api_key_assets=None
    )

    def _raise(*args, **kwargs):
        raise Exception("Simulated failure during asset revocation")

    monkeypatch.setattr(Nautilus, "revoke_publication", _raise)
    yield
    # Clean up
    Nautilus.configure(url=None, timeout=None, api_key_assets=None)


@pytest.mark.asyncio
async def test_delete_asset(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context,
        patch_nautilus_to_fail_revocation  # ... as there is no publication
):
    asset_id = asset_ids_in_data_context[0]
    async with initialized_beanie_context, data_context:
        response = await authenticated_async_client.request(
            "DELETE",
            f"/dataspace/manage/assets/{asset_id}",
            json={"nautilus_private_key": "42"}
        )
        assert response.status_code == 200
        assert response.json() is None
        # Confirm deletion in db
        asset_db = await Asset.get(asset_id)
        assert asset_db is None


@pytest.fixture
def patch_nautilus_to_avoid_external_revocation_request(
        authenticated_async_client, monkeypatch
):
    """
    Patch Nautilus to avoid external request for asset revocation
    """
    # Configure url to avoid failure of Nautilus constructor
    Nautilus.configure(
        url="http://nothing-here",
        timeout=None,
        api_key_assets=None
    )

    # Create mock for the httpx.AsyncClient.post method
    mock_post = AsyncMock(spec=httpx.AsyncClient.post)
    mock_post.return_value = httpx.Response(
        status_code=200,
        request=httpx.Request("POST", "http://nothing-here")
    )

    # Patch httpx.AsyncClient.post in the nautilus module to avoid external
    # request
    monkeypatch.setattr(
        nautilus.httpx.AsyncClient,
        "post",
        mock_post
    )

    yield

    # Clean up
    Nautilus.configure(url=None, timeout=None, api_key_assets=None)


@pytest.mark.asyncio
async def test_delete_asset_with_publication(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context,
        patch_nautilus_to_avoid_external_revocation_request
):
    asset_id = asset_ids_in_data_context[0]
    async with initialized_beanie_context, data_context:
        # Get one of the assets in the data_context, process it's definition
        # and add a publication
        asset = await Asset.get(asset_id)
        await asset.process_definition()
        asset.publication = Publication(
            did="some-did",
            asset_key="some-key",
            asset_url="http://some-url"
        )
        await asset.save()
        # Delete it
        response = await authenticated_async_client.request(
            "DELETE",
            f"/dataspace/manage/assets/{asset_id}",
            json={"nautilus_private_key": "42"}
        )
        assert response.status_code == 200
        assert response.json() is None
        # Confirm deletion in db
        asset_db = await Asset.get(asset_id)
        assert asset_db is None


@pytest.mark.asyncio
async def test_get_asset_dataset_not_ready(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context
):
    asset_id = asset_ids_in_data_context[0]
    async with initialized_beanie_context, data_context:
        # Attempt to retrieve asset data before the asset definition was
        # processed
        response = await authenticated_async_client.get(
            f"/dataspace/manage/assets/{asset_id}/data"
        )
    assert response.status_code == 400


@pytest.mark.asyncio
async def test_get_asset_dataset(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context,
        tmp_path
):
    asset_id = asset_ids_in_data_context[0]
    async with initialized_beanie_context, data_context:
        # Process asset definition
        asset = await Asset.get(asset_id)
        await asset.process_definition()
        # Attempt to retrieve asset data after successful processing
        response = await authenticated_async_client.get(
            f"/dataspace/manage/assets/{asset_id}/data"
        )
    assert response.status_code == 200
    # Download the archive and validate structure
    download_path = tmp_path / "download.zip"
    with open(download_path, "wb") as file:
        file.write(response.content)
    with ZipFile(download_path, "r") as archive:
        # Get a list of all members (files and directories) in the archive
        archive_members = archive.namelist()
        # Ensure the presence of the presence of the expected "cases/" and
        # "signals/" directories
        assert "cases/" in archive_members
        assert "signals/" in archive_members


@pytest.fixture
def patch_nautilus_to_fail_publication(
        authenticated_async_client, monkeypatch
):
    """
    Patch Nautilus to enforce failure of any attempt to publish to the
    dataspace.
    """
    # Configure url to avoid failure of Nautilus constructor
    Nautilus.configure(
        url="http://nothing-here",
        timeout=None,
        api_key_assets=None
    )

    def _raise():
        raise Exception("Simulated failure during dataset publication")

    monkeypatch.setattr(Nautilus, "publish_access_dataset", _raise)
    yield
    # Clean up
    Nautilus.configure(url=None, timeout=None, api_key_assets=None)


@pytest.mark.asyncio
async def test_publish_asset_not_ready(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context,
        patch_nautilus_to_fail_publication
):
    asset_id = asset_ids_in_data_context[0]
    async with initialized_beanie_context, data_context:
        # Attempt to publish asset before the asset definition was
        # processed
        response = await authenticated_async_client.post(
            f"/dataspace/manage/assets/{asset_id}/publication",
            json={"nautilus_private_key": "42"}
        )
    assert response.status_code == 400


@pytest.mark.asyncio
async def test_publish_asset_already_published(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context,
        patch_nautilus_to_fail_publication
):
    asset_id = asset_ids_in_data_context[0]
    async with initialized_beanie_context, data_context:
        # Get one of the assets in the data_context, process it's definition
        # and add a publication
        asset = await Asset.get(asset_id)
        await asset.process_definition()
        asset.publication = Publication(
            did="some-did",
            asset_key="some-key",
            asset_url="http://some-url"
        )
        await asset.save()
        # Attempt to publish the asset that already has a publication
        response = await authenticated_async_client.post(
            f"/dataspace/manage/assets/{asset_id}/publication",
            json={"nautilus_private_key": "42"}
        )
    # Response should indicate success but without creation of a new resource
    # via 200 status code.
    assert response.status_code == 200
    # Client should receive information about the existing publication
    assert response.json() == asset.publication.model_dump()


@pytest.fixture
def patch_nautilus_to_avoid_external_request(
        authenticated_async_client, monkeypatch
):
    """
    Patch Nautilus to just return a publication without first attempting any
    external http requests.
    """
    # Configure url to avoid failure of Nautilus constructor
    Nautilus.configure(
        url="http://nothing-here",
        timeout=None,
        api_key_assets=None
    )

    # Create mock of httpx.AsyncClient
    class MockAsyncClient:
        async def post(self, url, headers, timeout, json):
            return httpx.Response(
                status_code=201,
                request=httpx.Request("post", url),
                json={"assetdid": "newdid"}
            )

    # Patch httpx.AsyncClient.post in the nautilus module to avoid external
    # request
    monkeypatch.setattr(
        nautilus.httpx, "AsyncClient",  MockAsyncClient
    )
    yield
    # Clean up
    Nautilus.configure(url=None, timeout=None, api_key_assets=None)


@pytest.mark.asyncio
async def test_publish_asset(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context,
        patch_nautilus_to_avoid_external_request
):
    asset_id = asset_ids_in_data_context[0]
    async with initialized_beanie_context, data_context:
        # Process asset definition to allow publication
        asset = await Asset.get(asset_id)
        await asset.process_definition()
        # Attempt to publish to dataspace
        response = await authenticated_async_client.post(
            f"/dataspace/manage/assets/{asset_id}/publication",
            json={"nautilus_private_key": "42"}
        )
        # Status code should indicate creation of new resource
        assert response.status_code == 201
        # The asset db object should contain a publication including asset_key
        await asset.sync()
        assert asset.publication.asset_key
        # Response data should include all publication information except the
        # asset key
        assert response.json() == asset.publication.model_dump(
            exclude={"asset_key"}
        )


@pytest.fixture
def patch_nautilus_to_timeout_communication(
        authenticated_async_client, monkeypatch
):
    """
    Patch Nautilus such that external publication request times out.
    """
    # Configure url to avoid failure of Nautilus constructor
    Nautilus.configure(
        url="http://nothing-here",
        timeout=None,
        api_key_assets=None
    )

    # Patch httpx.AsyncClient.post in the nautilus module to timeout
    class MockAsyncClient:
        async def post(self, url, headers, timeout, json):
            raise httpx.TimeoutException(
                "Simulated timeout during dataset publication"
            )

    monkeypatch.setattr(
        nautilus.httpx, "AsyncClient", MockAsyncClient
    )
    yield
    # Clean up
    Nautilus.configure(url=None, timeout=None, api_key_assets=None)


@pytest.mark.asyncio
async def test_publish_asset_with_communication_timeout(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context,
        patch_nautilus_to_timeout_communication
):
    asset_id = asset_ids_in_data_context[0]
    async with initialized_beanie_context, data_context:
        # Process asset definition to allow publication
        asset = await Asset.get(asset_id)
        await asset.process_definition()
        # Attempt to publish to dataspace
        response = await authenticated_async_client.post(
            f"/dataspace/manage/assets/{asset_id}/publication",
            json={"nautilus_private_key": "42"}
        )
        # Http exception should indicate failed communication
        assert response.status_code == 500
        assert response.json()["detail"] == ("Failed communication with "
                                             "nautilus: Connection timeout.")


@pytest.fixture(params=[400, 401, 500, 501])
def patch_nautilus_to_fail_http_communication(
        authenticated_async_client, monkeypatch, request
):
    """
    Patch Nautilus such that external publication request fails with
    non-success http status code.
    """
    # Configure url to avoid failure of Nautilus constructor
    Nautilus.configure(
        url="http://nothing-here",
        timeout=None,
        api_key_assets=None
    )

    # Patch httpx.AsyncClient.post in the nautilus module to avoid external
    # request and to respond with non-success http code
    class MockAsyncClient:
        async def post(self, url, headers, timeout, json):
            return httpx.Response(
                status_code=request.param,
                text="Failed.",
                request=httpx.Request("post", url)
            )

    monkeypatch.setattr(
        nautilus.httpx, "AsyncClient", MockAsyncClient
    )
    yield
    # Clean up
    Nautilus.configure(url=None, timeout=None, api_key_assets=None)


@pytest.mark.asyncio
async def test_publish_asset_with_failed_http_communication(
        authenticated_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context,
        patch_nautilus_to_fail_http_communication
):
    asset_id = asset_ids_in_data_context[0]
    async with initialized_beanie_context, data_context:
        # Process asset definition to allow publication
        asset = await Asset.get(asset_id)
        await asset.process_definition()
        # Attempt to publish to dataspace
        response = await authenticated_async_client.post(
            f"/dataspace/manage/assets/{asset_id}/publication",
            json={"nautilus_private_key": "42"}
        )
        # Http exception should indicate failed communication
        assert response.status_code == 500
        assert response.json()["detail"] == ("Failed communication with "
                                             "nautilus: Failed.")


@pytest.mark.parametrize(
    "method,endpoint",
    [
        ("get", ""),
        ("delete", ""),
        ("get", "/data"),
        ("post", "/publication")
    ]
)
@pytest.mark.asyncio
async def test_asset_not_found(
        method,
        endpoint,
        authenticated_async_client,
        initialized_beanie_context
):
    # Fresh ID and no data initialization
    asset_id = str(ObjectId())
    async with initialized_beanie_context:
        response = await authenticated_async_client.request(
            method=method, url=f"/dataspace/manage/assets/{asset_id}{endpoint}"
        )
    assert response.status_code == 404
    assert response.json() == {
        "detail": f"No asset with id '{asset_id}' found."
    }


@pytest.mark.parametrize(
    "route", assets.management_router.routes, ids=lambda r: r.name
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
    jwt_payload["realm_access"]["roles"] = ["workshop", "not assets"]
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
    "route", assets.management_router.routes, ids=lambda r: r.name
)
def test_unauthorized_user(
        route, authenticated_client, signed_jwt_with_unauthorized_role
):
    """
    Endpoints should not be accessible, if the user role encoded in the
    token does not indicate assets access.
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
    "route", assets.management_router.routes, ids=lambda r: r.name
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
        "iat": (datetime.now(UTC) - timedelta(60)).timestamp(),
        "exp": (datetime.now(UTC) - timedelta(1)).timestamp(),
        "preferred_username": "user",
        "realm_access": {"roles": ["assets"]}
    }


@pytest.fixture
def expired_jwt(expired_jwt_payload, rsa_private_key_pem: bytes):
    """Create an expired JWT signed with private RSA key."""
    return jws.sign(
        expired_jwt_payload, rsa_private_key_pem, algorithm="RS256"
    )


@pytest.mark.parametrize(
    "route", assets.management_router.routes, ids=lambda r: r.name
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


@pytest.fixture
def public_async_client(app, base_url):
    """
    Client to access the public dataspace router. Does not have a Bearer
    token issued by keycloak.
    """
    client = httpx.AsyncClient(
        transport=httpx.ASGITransport(app=app),
        base_url=base_url
    )
    return client


@pytest.mark.asyncio
async def test_get_published_dataset(
        authenticated_async_client,
        public_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context,
        patch_nautilus_to_avoid_external_request,
        tmp_path
):
    asset_id = asset_ids_in_data_context[0]
    async with (initialized_beanie_context, data_context):
        # Get one of the assets in the data_context, process it's definition
        # and have the client authenticated for management publish it
        asset = await Asset.get(asset_id)
        await asset.process_definition()
        await authenticated_async_client.post(
            f"/dataspace/manage/assets/{asset_id}/publication",
            json={"nautilus_private_key": "42"}
        )
        # As part of the publishing process, an asset_url and asset_key were
        # created. Fetch those from the db, as the public client will need
        # them to access the asset data archive.
        await asset.sync()
        asset_url = asset.publication.asset_url
        asset_key = asset.publication.asset_key
        # Confirm expectation about the constructed URL
        assert asset_url == (f"{str(public_async_client.base_url)}/dataspace/"
                             f"public/assets/{asset_id}/data")

        # Now do the actual testing: Can the public client access the asset
        # data archive using the automatically created url and key?
        response = await public_async_client.get(
            asset_url,
            headers={"data_key": asset_key, "x-api-key": "assets-key-dev"}
        )
        assert response.status_code == 200
        # Download the archive and validate structure
        download_path = tmp_path / "download.zip"
        with open(download_path, "wb") as file:
            file.write(response.content)
        with ZipFile(download_path, "r") as archive:
            # Get a list of all members (files and directories) in the archive
            archive_members = archive.namelist()
            # Ensure the presence of the presence of the expected "cases/" and
            # "signals/" directories
            assert "cases/" in archive_members
            assert "signals/" in archive_members


@pytest.mark.asyncio
async def test_get_published_dataset_invalid_asset_key(
        authenticated_async_client,
        public_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context,
        patch_nautilus_to_avoid_external_request
):
    asset_id = asset_ids_in_data_context[0]
    async with (initialized_beanie_context, data_context):
        # Get one of the assets in the data_context, process it's definition
        # and have the client authenticated for management publish it
        asset = await Asset.get(asset_id)
        await asset.process_definition()
        await authenticated_async_client.post(
            f"/dataspace/manage/assets/{asset_id}/publication",
            json={"nautilus_private_key": "42"}
        )
        # As part of the publishing process, an asset_url and asset_key were
        # created. Only fetch the url here.
        await asset.sync()
        asset_url = asset.publication.asset_url
        # Confirm expectation about the constructed URL
        assert asset_url == (f"{str(public_async_client.base_url)}/dataspace/"
                             f"public/assets/{asset_id}/data")

        # Now do the actual testing: The asset url is valid, but the public
        # client can not access the dataset with an invalid asset_key
        response = await public_async_client.get(
            asset_url,
            headers={
                "data_key": "this-sure-is-not-the-right-key",
                "x-api-key": "assets-key-dev"}
        )
        assert response.status_code == 401
        assert response.json() == {"detail": "Could not validate asset key."}


@pytest.mark.asyncio
async def test_get_published_dataset_asset_not_published(
        public_async_client,
        initialized_beanie_context,
        data_context,
        asset_ids_in_data_context
):
    # Id of an unpublished asset in the data context
    asset_id = asset_ids_in_data_context[0]
    async with (initialized_beanie_context, data_context):
        # If the asset would be published, this would be the url for data
        # retrieval by the public client.
        asset_url = f"/dataspace/public/assets/{asset_id}/data"
        # Public client tries to fetch the data (maybe the asset was published
        # in the past)
        response = await public_async_client.get(
            asset_url,
            headers={"data_key": "some-key", "x-api-key": "assets-key-dev"}
        )
        assert response.status_code == 404
        assert response.json() == {
            "detail": f"No published asset with ID '{asset_id}' found."
        }


@pytest.mark.asyncio
async def test_get_published_dataset_asset_invalid_asset_id(
        public_async_client,
        initialized_beanie_context
):
    async with (initialized_beanie_context):
        # Public client attempts to fetch an asset that does not exist at all
        # (Note: No data context here and new asset id)
        asset_id = str(ObjectId())
        asset_url = f"/dataspace/public/assets/{asset_id}/data"
        response = await public_async_client.get(
            asset_url,
            headers={"data_key": "some-key", "x-api-key": "assets-key-dev"}
        )
        assert response.status_code == 404
        assert response.json() == {
            "detail": f"No asset with id '{asset_id}' found."
        }


def test_get_published_dataset_no_asset_key(unauthenticated_client):
    any_asset_id = str(ObjectId())
    response = unauthenticated_client.get(
        f"/dataspace/public/assets/{any_asset_id}/data",
        headers={"x-api-key": "assets-key-dev"}
    )
    assert response.status_code == 403
    assert response.json() == {"detail": "Not authenticated"}


def test_get_published_dataset_no_asset_api_key(unauthenticated_client):
    any_asset_id = str(ObjectId())
    response = unauthenticated_client.get(
        f"/dataspace/public/assets/{any_asset_id}/data",
        headers={"x-api-key": "assets-key-dev"}
    )
    assert response.status_code == 403
    assert response.json() == {"detail": "Not authenticated"}
