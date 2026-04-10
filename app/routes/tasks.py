from fastapi import APIRouter, HTTPException
from app.models.task import Task, TaskCreate, tasks, add_task, get_task, delete_task

router = APIRouter()


@router.get("/tasks", response_model=list[Task])
def list_tasks():
    return tasks


@router.post("/tasks", response_model=Task, status_code=201)
def create_task(data: TaskCreate):
    return add_task(data)


@router.get("/tasks/{task_id}", response_model=Task)
def read_task(task_id: int):
    task = get_task(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@router.delete("/tasks/{task_id}", status_code=204)
def remove_task(task_id: int):
    if not delete_task(task_id):
        raise HTTPException(status_code=404, detail="Task not found")
