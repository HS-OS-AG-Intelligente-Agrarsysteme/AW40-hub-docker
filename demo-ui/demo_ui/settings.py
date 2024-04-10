from pydantic import BaseSettings


class Settings(BaseSettings):
    hub_api_base_url: str = "http://api:8000/v1"
    hub_api_host_url: str = "http://127.0.0.1:8000/v1"

    keycloak_url: str = "http://keycloak:8080"
    keycloak_workshop_realm: str = "werkstatt-hub"
    keycloak_client_id: str = "aw40hub-dev-client"
    keycloak_client_secret: str = "N5iImyRP1bzbzXoEYJ6zZMJx0XWiqhCw"
    # Note: Keycloak client credentials correspond to the dev client created
    # if keycloak/keycloak-config-dev.sh

    session_secret: str = "demo-ui-session-secret"

    timezone: str = "Europe/Berlin"


settings = Settings()
