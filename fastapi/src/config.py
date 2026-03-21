from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    port: int = PROJECT_PORT
    host: str = "127.0.0.1"
    database_path: str = "./data/PROJECT_NAME.db"
    api_token: str = "changeme"
    log_level: str = "INFO"
    max_request_bytes: int = 5_242_880

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
