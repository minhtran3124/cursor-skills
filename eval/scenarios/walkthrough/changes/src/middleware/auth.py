from functools import wraps
from flask import request, jsonify

API_KEYS = {"dev-key-001", "dev-key-002"}


def require_auth(f):
    """Decorator that enforces API key authentication on endpoints."""

    @wraps(f)
    def decorated(*args, **kwargs):
        api_key = request.headers.get("X-API-Key")
        if not api_key or api_key not in API_KEYS:
            return jsonify({"error": "Unauthorized", "message": "Valid API key required"}), 401
        return f(*args, **kwargs)

    return decorated
