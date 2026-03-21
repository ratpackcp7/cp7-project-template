from flask import Blueprint, jsonify, request
from app.database import create_example, get_example, list_examples

bp = Blueprint("api", __name__, url_prefix="/api/v1")


@bp.route("/examples", methods=["POST"])
def api_create_example():
    data = request.get_json()
    if not data or "name" not in data:
        return jsonify({"error": "name is required"}), 400
    result = create_example(data["name"])
    return jsonify(result)


@bp.route("/examples/<int:example_id>")
def api_get_example(example_id):
    result = get_example(example_id)
    if not result:
        return jsonify({"error": "Not found"}), 404
    return jsonify(result)


@bp.route("/examples")
def api_list_examples():
    limit = request.args.get("limit", 50, type=int)
    offset = request.args.get("offset", 0, type=int)
    return jsonify(list_examples(limit=limit, offset=offset))
