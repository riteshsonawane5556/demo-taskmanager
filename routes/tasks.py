from fastapi import APIRouter, HTTPException, Query
from typing import List, Literal, Optional
from models import Task, TaskCreate, TaskStats, TaskUpdate
from datetime import datetime, timezone

router = APIRouter()

tasks: List[Task] = []
_id_counter = 1


@router.get("/tasks", response_model=List[Task])
def list_tasks(
    sort_by: Literal["created_at", "updated_at", "due_date", "title"] = Query("created_at", description="Field to sort by"),
    order: Literal["asc", "desc"] = Query("asc", description="Sort direction"),
    due_before: Optional[datetime] = Query(None, description="Filter tasks due before this datetime"),
    due_after: Optional[datetime] = Query(None, description="Filter tasks due after this datetime"),
):
    def sort_key(task: Task):
        value = getattr(task, sort_by)
        if value is None:
            return (1, "")
        return (0, value)

    result = tasks
    if due_before is not None:
        result = [t for t in result if t.due_date is not None and t.due_date <= due_before]
    if due_after is not None:
        result = [t for t in result if t.due_date is not None and t.due_date >= due_after]

    return sorted(result, key=sort_key, reverse=(order == "desc"))


@router.get("/tasks/search", response_model=List[Task])
def search_tasks(
    q: Optional[str] = Query(None, description="Search in title or description"),
    completed: Optional[bool] = Query(None, description="Filter by completion status"),
):
    result = tasks
    if q:
        q_lower = q.lower()
        result = [
            t for t in result
            if q_lower in t.title.lower() or (t.description and q_lower in t.description.lower())
        ]
    if completed is not None:
        result = [t for t in result if t.completed == completed]
    return result


@router.get("/tasks/stats", response_model=TaskStats)
def get_task_stats():
    completed = sum(1 for t in tasks if t.completed)
    return TaskStats(total=len(tasks), completed=completed, pending=len(tasks) - completed)


@router.get("/tasks/overdue", response_model=List[Task])
def get_overdue_tasks():
    now = datetime.now(timezone.utc).replace(tzinfo=None)
    return [t for t in tasks if t.due_date is not None and t.due_date < now and not t.completed]


@router.patch("/tasks/{task_id}/complete", response_model=Task)
def mark_task_complete(task_id: int):
    for i, task in enumerate(tasks):
        if task.id == task_id:
            tasks[i] = task.model_copy(update={"completed": True})
            return tasks[i]
    raise HTTPException(status_code=404, detail="Task not found")


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
        priority=payload.priority,
        due_date=payload.due_date,
        created_at=datetime.utcnow(),
    )
    tasks.append(task)
    _id_counter += 1
    return task


@router.put("/tasks/{task_id}", response_model=Task)
def update_task(task_id: int, payload: TaskUpdate):
    for i, task in enumerate(tasks):
        if task.id == task_id:
            updated = task.model_copy(update={**payload.model_dump(exclude_unset=True), "updated_at": datetime.utcnow()})
            tasks[i] = updated
            return updated
    raise HTTPException(status_code=404, detail="Task not found")


@router.delete("/tasks/{task_id}", status_code=204, response_model=None)
def delete_task(task_id: int):
    for i, task in enumerate(tasks):
        if task.id == task_id:
            tasks.pop(i)
            return
    raise HTTPException(status_code=404, detail="Task not found")
