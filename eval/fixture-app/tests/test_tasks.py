import json
import pytest
from src.app import create_app


@pytest.fixture
def client():
    app = create_app()
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_create_task(client):
    response = client.post(
        "/api/tasks",
        data=json.dumps({"title": "Write tests", "priority": 2}),
        content_type="application/json",
    )
    assert response.status_code == 201
    data = response.get_json()
    assert data["title"] == "Write tests"
    assert data["priority"] == 2


def test_create_task_missing_title(client):
    response = client.post(
        "/api/tasks",
        data=json.dumps({"priority": 1}),
        content_type="application/json",
    )
    assert response.status_code == 400


def test_list_tasks(client):
    client.post(
        "/api/tasks",
        data=json.dumps({"title": "Task 1"}),
        content_type="application/json",
    )
    response = client.get("/api/tasks")
    assert response.status_code == 200
    data = response.get_json()
    assert len(data) >= 1


def test_get_task_not_found(client):
    response = client.get("/api/tasks/999")
    assert response.status_code == 404
