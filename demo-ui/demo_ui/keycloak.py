import httpx
from typing import Optional


class Keycloak:
    """
    Utils to fetch API access tokens from keycloak.
    """

    def __init__(
            self,
            keycloak_url: str,
            realm: str,
            client_id: str,
            client_secret: Optional[str] = None
    ):
        self.keycloak_url = keycloak_url
        self.realm = realm
        self.client_id = client_id
        self.client_secret = client_secret
        # HTTP Client to interact with keycloak api
        self.http_client = httpx.Client(
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )

    @property
    def token_url(self):
        return f"{self.keycloak_url}/realms/{self.realm}/protocol/" \
               f"openid-connect/token"

    @staticmethod
    def _response_indicates_invalid_user_credentials(response: httpx.Response):
        """
        Check if a response issued by keycloak indicates invalid user
        credentials in the token request.
        """
        unauthorized = response.status_code == 401
        if unauthorized:
            return response.json().get(
                "error_description", None
            ) == "Invalid user credentials"
        return False

    def get_tokens(
            self, username: str, password: str
    ) -> tuple[str, str]:
        """
        Get access and refresh tokens from keycloak via (user) password grant.
        """
        payload = f"client_id={self.client_id}&username={username}&" \
                  f"password={password}&grant_type=password"
        if self.client_secret:
            payload += f"&client_secret={self.client_secret}"
        response = self.http_client.post(self.token_url, data=payload)

        if self._response_indicates_invalid_user_credentials(response):
            return None, None
        response.raise_for_status()

        response_data = response.json()
        return response_data["access_token"], response_data["refresh_token"]

    @staticmethod
    def _response_indicates_expired_token(response: httpx.Response):
        """
        Check if a response issued by keycloak indicates an expired refresh
        token in the token request.
        """
        bad_request = response.status_code == 400
        if bad_request:
            return response.json().get(
                "error_description", None
            ) == "Token is not active"
        return False

    def refresh_tokens(self, refresh_token) -> tuple[str, str]:
        """
        Get new access and refresh tokens from keycloak via refresh_token
        grant.
        """
        payload = f"client_id={self.client_id}&refresh_token={refresh_token}" \
                  f"&grant_type=refresh_token"
        if self.client_secret:
            payload += f"&client_secret={self.client_secret}"
        response = self.http_client.post(self.token_url, data=payload)

        if self._response_indicates_expired_token(response):
            return None, None
        response.raise_for_status()

        response_data = response.json()
        return response_data["access_token"], response_data["refresh_token"]
