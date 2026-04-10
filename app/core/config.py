from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "Task Tracker API"
    app_version: str = "0.1.0"


settings = Settings()
