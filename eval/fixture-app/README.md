# Task Tracker API

A simple REST API for managing tasks, built with Flask.

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | /api/tasks | List all tasks |
| POST | /api/tasks | Create a new task |
| GET | /api/tasks/:id | Get a task by ID |
| PUT | /api/tasks/:id | Update a task |

## Setup

```bash
pip install -r requirements.txt
python -m src.app
```

## Tests

```bash
pytest
```

## Project Structure

```
src/
  app.py              # Flask app factory
  routes/tasks.py     # API endpoints
  models/task.py      # Task model + in-memory store
  utils/validators.py # Input validation
tests/
  test_tasks.py       # API tests
```
