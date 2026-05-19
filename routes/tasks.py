from fastapi import APIRouter, HTTPException
from typing import List
from models import Task, TaskCreate, TaskUpdate
from datetime import datetime

router = APIRouter()

tasks: List[Task] = []
_id_counter = 1


@router.get("/tasks", response_model=List[Task])
def list_tasks():
    return tasks


@router.get("/tasks/{task_id}", response_model=Task)
def get_task(task_id: int):
    for task in tasks:
        if task.id == task_id:
            return task
    raise HTTPException(status_code=404, detail="Task not found")


@router.post("/tasks", response_model=Task, status_code=201)
def create_task(payload: TaskCreate):
    global _id_counter
    task = Task(
        id=_id_counter,
        title=payload.title,
        description=payload.description,
        completed=payload.completed,
        created_at=datetime.utcnow(),
    )
    tasks.append(task)
    _id_counter += 1
    return task


@router.put("/tasks/{task_id}", response_model=Task)
def update_task(task_id: int, payload: TaskUpdate):
    for i, task in enumerate(tasks):
        if task.id == task_id:
            updated = task.model_copy(update=payload.model_dump(exclude_unset=True))
            tasks[i] = updated
            return updated
    raise HTTPException(status_code=404, detail="Task not found")


@router.delete("/tasks/{task_id}", status_code=204)
def delete_task(task_id: int):
    for i, task in enumerate(tasks):
        if task.id == task_id:
            tasks.pop(i)
            return
    raise HTTPException(status_code=404, detail="Task not found")
