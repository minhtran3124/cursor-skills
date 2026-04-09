from flask import Blueprint, request, jsonify
from src.models.task import store
from src.utils.validators import validate_task_input

tasks_bp = Blueprint("tasks", __name__)


@tasks_bp.route("/tasks", methods=["GET"])
def list_tasks():
    tasks = store.list_all()
    return jsonify([vars(t) for t in tasks])


@tasks_bp.route("/tasks", methods=["POST"])
def create_task():
    data = request.get_json()
    errors = validate_task_input(data)
    if errors:
        return jsonify({"errors": errors}), 400

    task = store.add(
        title=data["title"],
        description=data.get("description", ""),
        priority=data.get("priority", 1),
    )
    return jsonify(vars(task)), 201


@tasks_bp.route("/tasks/<int:task_id>", methods=["GET"])
def get_task(task_id):
    task = store.get(task_id)
    if not task:
        return jsonify({"error": "Task not found"}), 404
    return jsonify(vars(task))


@tasks_bp.route("/tasks/<int:task_id>", methods=["PUT"])
def update_task(task_id):
    task = store.get(task_id)
    if not task:
        return jsonify({"error": "Task not found"}), 404

    data = request.get_json()
    updated = store.update(task_id, **data)
    return jsonify(vars(updated))


@tasks_bp.route("/tasks/<int:task_id>", methods=["DELETE"])
def delete_task(task_id):
    task = store.delete(task_id)
    if not task:
        return jsonify({"error": "Task not found"}), 404
    return jsonify({"message": f"Task {task_id} deleted"}), 200
