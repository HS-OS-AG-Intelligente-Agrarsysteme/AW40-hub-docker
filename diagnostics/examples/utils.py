import httpx


def get_workshop_token_from_keycloak(
    kc_url: str = "localhost:8080",
    kc_realm: str = "werkstatt-hub",
    kc_workshop_id: str = "aw40hub-dev-workshop",
    kc_workshop_password: str = "dev",
    kc_client_id: str = "aw40hub-dev-client",
    kc_client_secret: str = "N5iImyRP1bzbzXoEYJ6zZMJx0XWiqhCw"
) -> str:
    """Get a jwt to access the API's /workshop endpoints.

    Default parameters correspond to keycloak development configuration
    applied via keycloak/keycloak-config-dev.sh.
    """
    token_url: str = f"http://{kc_url}/realms/{kc_realm}/protocol/" \
                     f"openid-connect/token"
    payload = f"client_id={kc_client_id}&client_secret={kc_client_secret}&" \
              f"username={kc_workshop_id}&password={kc_workshop_password}" \
              f"&grant_type=password"
    headers = {"Content-Type": "application/x-www-form-urlencoded"}
    response = httpx.post(token_url, headers=headers, data=payload)
    response.raise_for_status()
    return response.json()["access_token"]
