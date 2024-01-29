import pytest
from api.security.api_key_auth import APIKeyAuth
from fastapi import HTTPException


class TestAPIKeyAuth:

    def test_no_valid_key_specified(self):
        key_auth = APIKeyAuth()
        with pytest.raises(AttributeError):
            key_auth("any key")

    def test_successful_validation(self):
        valid_key = "42!"
        key_auth = APIKeyAuth()
        key_auth.valid_key = valid_key
        assert key_auth(valid_key)

    def test_failed_validation(self):
        valid_key = "42!"
        invalid_key = valid_key[1:]
        key_auth = APIKeyAuth()
        key_auth.valid_key = valid_key
        with pytest.raises(HTTPException) as e:
            key_auth(invalid_key)
            assert e.status_code == 401
