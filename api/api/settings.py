from pydantic import BaseSettings


class Settings(BaseSettings):
    api_allow_origins: str
    mongo_host: str
    mongo_username: str
    mongo_password: str
    mongo_db: str

    redis_password: str
    redis_host: str = "redis"
    redis_port: str = "6379"

    @property
    def mongo_uri(self):
        username = self.mongo_username
        password = self.mongo_password
        host = self.mongo_host

        return (
            f"mongodb://{username}:{password}"
            f"@{host}:27017/?authSource=admin"
        )

    @property
    def allowed_origins(self):
        return [x for x in self.api_allow_origins.split(',') if x]

    @property
    def redis_uri(self):
        return (
            f"redis://:{self.redis_password}@{self.redis_host}"
            f":{self.redis_port}"
        )


settings = Settings()
