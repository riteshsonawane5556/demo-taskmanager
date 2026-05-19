from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes.tasks import router as tasks_router

app = FastAPI(title="Task Manager API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(tasks_router, prefix="/api/v1")


@app.get("/")
def root():
    return {"message": "Task Manager API", "status": "running"}
