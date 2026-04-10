import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.models.task import reset_store


@pytest.fixture(autouse=True)
def clean_store():
    reset_store()
    yield
    reset_store()


client = TestClient(app)


def test_create_task():
    resp = client.post("/api/tasks", json={"title": "Buy milk"})
    assert resp.status_code == 201
    data = resp.json()
    assert data["title"] == "Buy milk"
    assert data["done"] is False
    assert data["id"] == 1


def test_create_task_empty_title():
    resp = client.post("/api/tasks", json={"title": ""})
    assert resp.status_code == 422


def test_list_tasks():
    client.post("/api/tasks", json={"title": "Task 1"})
    client.post("/api/tasks", json={"title": "Task 2"})
    resp = client.get("/api/tasks")
    assert resp.status_code == 200
    assert len(resp.json()) == 2


def test_get_task():
    client.post("/api/tasks", json={"title": "Find me"})
    resp = client.get("/api/tasks/1")
    assert resp.status_code == 200
    assert resp.json()["title"] == "Find me"


def test_get_task_not_found():
    resp = client.get("/api/tasks/999")
    assert resp.status_code == 404


def test_delete_task():
    client.post("/api/tasks", json={"title": "Delete me"})
    resp = client.delete("/api/tasks/1")
    assert resp.status_code == 204

    resp = client.get("/api/tasks/1")
    assert resp.status_code == 404


def test_delete_task_not_found():
    resp = client.delete("/api/tasks/999")
    assert resp.status_code == 404
