from flask import Flask
from src.routes.tasks import tasks_bp


def create_app():
    app = Flask(__name__)
    app.config["AUTH_ENABLED"] = True
    app.register_blueprint(tasks_bp, url_prefix="/api")
    return app


if __name__ == "__main__":
    app = create_app()
    app.run(debug=True, port=5000)
