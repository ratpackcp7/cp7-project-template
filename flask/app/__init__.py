import logging
import os

from flask import Flask

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)


def create_app():
    app = Flask(__name__)
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "dev-secret-change-me")
    app.config["DATABASE_PATH"] = os.getenv("DATABASE_PATH", "./data/PROJECT_NAME.db")
    os.makedirs("./data", exist_ok=True)

    from app.database import init_db
    init_db(app.config["DATABASE_PATH"])

    from app.routes import bp
    app.register_blueprint(bp)

    @app.route("/health")
    def health():
        return {"status": "ok", "service": "PROJECT_NAME"}

    @app.after_request
    def add_cors_headers(response):
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS"
        response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
        return response

    logger.info("PROJECT_NAME initialized")
    return app
