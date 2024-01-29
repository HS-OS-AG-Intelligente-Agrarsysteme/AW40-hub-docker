import httpx


def _response_indicates_invalid_user_credentials(response: httpx.Response):
    unauthorized = response.status_code == 401
    if unauthorized:
        return response.json().get(
            "error_description", None
        ) == "Invalid user credentials"
    return False


def get_tokens(
        keycloak_url, realm, client_id, client_secret, username, password
) -> tuple[str, str]:
    token_url = f"{keycloak_url}/realms/{realm}/protocol/openid-connect/token"
    headers = {"Content-Type": "application/x-www-form-urlencoded"}
    payload = f"client_id={client_id}&username={username}&" \
              f"password={password}&grant_type=password"
    if client_secret:
        payload += f"&client_secret={client_secret}"
    response = httpx.post(token_url, headers=headers, data=payload)

    if _response_indicates_invalid_user_credentials(response):
        return None, None
    response.raise_for_status()

    response_data = response.json()
    return response_data["access_token"], response_data["refresh_token"]
