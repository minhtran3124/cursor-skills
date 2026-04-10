from pydantic import BaseModel, Field


class TaskCreate(BaseModel):
    title: str = Field(..., min_length=1)
    done: bool = False


class Task(BaseModel):
    id: int
    title: str
    done: bool = False


# In-memory storage
tasks: list[Task] = []
next_id: int = 1


def add_task(data: TaskCreate) -> Task:
    global next_id
    task = Task(id=next_id, title=data.title, done=data.done)
    tasks.append(task)
    next_id += 1
    return task


def get_task(task_id: int) -> Task | None:
    return next((t for t in tasks if t.id == task_id), None)


def delete_task(task_id: int) -> bool:
    task = get_task(task_id)
    if task:
        tasks.remove(task)
        return True
    return False


def reset_store():
    global next_id
    tasks.clear()
    next_id = 1
