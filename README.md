Build a simple FastAPI application with the following structure and requirements:

## Project: Simple Task Manager API

### Setup
project already initialized with uv
- Required packages: fastapi, uvicorn, pydantic

### File Structure to Create
task-manager/
├── main.py
├── models.py
├── routes/
│   └── tasks.py
├── requirements.txt


### Models (models.py) 
Create a Task model with Pydantic:
- id: int
- title: str (required)
- description: str (optional)
- completed: bool (default: False)
- created_at: datetime (auto-set)

### API Endpoints (routes/tasks.py)
Build full CRUD:
- GET    /tasks         → list all tasks
- GET    /tasks/{id}    → get single task
- POST   /tasks         → create task
- PUT    /tasks/{id}    → update task
- DELETE /tasks/{id}    → delete task

Use an in-memory list as the data store (no database needed).

### Main App (main.py)
- Create FastAPI app instance
- Include the tasks router with prefix /api/v1
- Add a root endpoint GET / that returns {"message": "Task Manager API", "status": "running"}
- Enable CORS for all origins


fastapi
uvicorn
pydantic



### After creating all files:
uv install
2. Verify the app starts with `uvicorn main:app --reload --port 8000`
3. Test all endpoints using curl to confirm they work
4. Show me the output of each test

Do all of this step by step, create the files, install dependencies, run the server, and test it.
