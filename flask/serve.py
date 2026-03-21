import os
from werkzeug.middleware.proxy_fix import ProxyFix
from waitress import serve
from app import create_app

app = create_app()
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)

if __name__ == "__main__":
    port = int(os.getenv("PORT", "PROJECT_PORT"))
    host = os.getenv("HOST", "127.0.0.1")
    print(f"PROJECT_NAME starting on {host}:{port}")
    serve(app, host=host, port=port)
