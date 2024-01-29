import pytest

import httpx
from api.security.keycloak import Keycloak


@pytest.fixture
def keycloak_url():
    return "http://testcloak:8080"


@pytest.fixture
def workshop_realm():
    return "test-realm"


@pytest.fixture
def raw_public_key():
    return "test key line 1\n" \
           "test key line 2"


@pytest.fixture()
def patch_successful_http_request(
        monkeypatch, keycloak_url, workshop_realm, raw_public_key
):
    def mock_get(url):
        assert url == f"{keycloak_url}/realms/{workshop_realm}"
        return httpx.Response(
            status_code=200,
            json={"public_key": raw_public_key},
            request=httpx.Request(url=url, method="GET")
        )
    monkeypatch.setattr(httpx, "get", mock_get)


@pytest.fixture()
def patch_failed_http_request(
        monkeypatch, keycloak_url, workshop_realm
):
    def mock_get(url):
        assert url == f"{keycloak_url}/realms/{workshop_realm}"
        return httpx.Response(
            status_code=400,
            request=httpx.Request(url=url, method="GET")
        )
    monkeypatch.setattr(httpx, "get", mock_get)


@pytest.fixture(autouse=True)
def delete_configuration():
    """Wipe configuration after each test."""
    yield
    Keycloak._url = None
    Keycloak._workshop_realm = None


class TestKeycloak:

    def test_configure(
            self,
            keycloak_url,
            workshop_realm,
            raw_public_key,
            patch_successful_http_request
    ):
        Keycloak.configure(keycloak_url, workshop_realm)

    def test_configure_fails(
            self,
            keycloak_url,
            workshop_realm,
            patch_failed_http_request
    ):
        with pytest.raises(httpx.HTTPStatusError):
            Keycloak.configure(keycloak_url, workshop_realm)

    def test_get_public_key_for_workshop_realm(
            self,
            keycloak_url,
            workshop_realm,
            raw_public_key,
            patch_successful_http_request
    ):
        Keycloak.configure(keycloak_url, workshop_realm)
        retrieved_pubkey = Keycloak.get_public_key_for_workshop_realm()
        lines = retrieved_pubkey.split("\n")
        assert lines[0] == "-----BEGIN PUBLIC KEY-----"
        assert lines[-1] == "-----END PUBLIC KEY-----"
        assert "\n".join(lines[1:-1]) == raw_public_key
