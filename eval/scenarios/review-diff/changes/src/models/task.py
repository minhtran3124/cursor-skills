from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional


@dataclass
class Task:
    id: int
    title: str
    description: str = ""
    priority: int = 1
    completed: bool = False
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())


class TaskStore:
    """In-memory task storage."""

    def __init__(self):
        self._tasks: dict[int, Task] = {}
        self._next_id = 1

    def add(self, title: str, description: str = "", priority: int = 1) -> Task:
        task = Task(
            id=self._next_id,
            title=title,
            description=description,
            priority=priority,
        )
        self._tasks[self._next_id] = task
        self._next_id += 1
        return task

    def get(self, task_id: int) -> Optional[Task]:
        return self._tasks.get(task_id)

    def list_all(self) -> list[Task]:
        return list(self._tasks.values())

    def update(self, task_id: int, **kwargs) -> Optional[Task]:
        task = self._tasks.get(task_id)
        if not task:
            return None
        for key, value in kwargs.items():
            if hasattr(task, key):
                setattr(task, key, value)
        return task

    def delete(self, task_id: int) -> Optional[Task]:
        return self._tasks.pop(task_id, None)


store = TaskStore()
