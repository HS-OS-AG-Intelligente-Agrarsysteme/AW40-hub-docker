import httpx


class Keycloak:
    """Utils to interface keycloak."""

    _url: str = None  # root url or the keycloak server
    _workshop_realm: str = None  # name of realm with workshop users

    @classmethod
    def configure(cls, url: str, workshop_realm: str):
        """Configure keycloak connection details."""
        cls._url = url
        cls._workshop_realm = workshop_realm
        # confirm working configuration
        cls.get_public_key_for_workshop_realm()

    @classmethod
    def get_public_key(cls, realm: str) -> str:
        """Get public rsa key for a realm from keycloak."""
        response = httpx.get(f"{cls._url}/realms/{realm}")
        response.raise_for_status()
        pubkey_raw = response.json()["public_key"]
        pubkey = f"-----BEGIN PUBLIC KEY-----\n" \
                 f"{pubkey_raw}\n" \
                 f"-----END PUBLIC KEY-----"
        return pubkey

    @classmethod
    def get_public_key_for_workshop_realm(cls) -> str:
        """Get public rsa key for the workshop realm."""
        return cls.get_public_key(realm=cls._workshop_realm)
