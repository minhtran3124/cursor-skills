# Plan: Init FastAPI Project

## Goal

Set up a minimal FastAPI project with a clean folder structure, one working CRUD endpoint, and basic config.

## Changes

### 1. Project scaffold

Create the folder structure:

```
app/
  __init__.py
  main.py            # FastAPI app entry point
  routes/
    __init__.py
    tasks.py          # Task CRUD routes
  models/
    __init__.py
    task.py            # Task Pydantic models
  core/
    __init__.py
    config.py          # App settings
requirements.txt
```

### 2. App entry point

`app/main.py` — create FastAPI app, register the tasks router.

### 3. Models

`app/models/task.py` — Pydantic models for Task (id, title, done). Use an in-memory list as storage.

### 4. Routes

`app/routes/tasks.py` — CRUD endpoints:
- `GET /tasks` — list all
- `POST /tasks` — create
- `GET /tasks/{id}` — get one
- `DELETE /tasks/{id}` — delete

### 5. Config

`app/core/config.py` — app name and version via pydantic-settings.

### 6. Requirements

`requirements.txt` — fastapi, uvicorn.
