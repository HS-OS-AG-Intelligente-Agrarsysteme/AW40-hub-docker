import pytest

from examples.utils import get_workshop_token_from_keycloak


@pytest.fixture
def api_token():
    return get_workshop_token_from_keycloak()
