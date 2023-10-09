from pydantic import BaseSettings


class Settings(BaseSettings):
    hub_api_base_url: str = "http://127.0.0.1:8000/v1"


settings = Settings()
