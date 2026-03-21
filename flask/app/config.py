import os

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-change-me")
    DATABASE_PATH = os.getenv("DATABASE_PATH", "./data/PROJECT_NAME.db")
    PORT = int(os.getenv("PORT", "PROJECT_PORT"))
    HOST = os.getenv("HOST", "127.0.0.1")
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
