# Plan: Add search and filtering to Task API

## Goal

Add the ability to search tasks by title and filter by priority and completion status. This is the most requested feature from API consumers.

## Changes

### 1. Add query parameters to GET /api/tasks

Support the following optional query parameters:
- `q` — search tasks by title (case-insensitive substring match)
- `priority` — filter by exact priority level (1-5)
- `completed` — filter by completion status (true/false)

Parameters can be combined: `GET /api/tasks?q=deploy&priority=3&completed=false`

### 2. Add search and filter methods to TaskStore

Add methods to `TaskStore` in `src/models/task.py`:
- `search(query: str)` — returns tasks where title contains query (case-insensitive)
- `filter_by(priority: int | None, completed: bool | None)` — returns filtered tasks

Keep the existing `list_all()` method unchanged for backward compatibility.

### 3. Add tests for search and filtering

Add tests in `tests/test_tasks.py`:
- Test search returns matching tasks
- Test search with no results returns empty list
- Test priority filter
- Test completed filter
- Test combining search + filter
- Test that GET /api/tasks with no params still returns all tasks (backward compat)
