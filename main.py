from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from models import User, StudyRequest, AskQuery, SmartScheduleRequest
from planner import generate_study_plan
from tutor import ask_learnflow
from progress import save_progress, get_progress
from smart_scheduler import generate_smart_schedule

app = FastAPI(title="LearnFlow API")

# ✅ Allow cross-origin requests (needed for Flutter on Chrome)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change to specific domain for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 🧠 In-memory user store
users = {}

@app.get("/")
def home():
    return {"message": "Welcome to LearnFlow API"}

@app.post("/register")
def register(user: User):
    """Registers a new user"""
    if user.username in users:
        raise HTTPException(status_code=400, detail="User already exists")
    users[user.username] = user.dict()
    return {"message": "User registered successfully"}

@app.post("/plan")
def study_plan(req: StudyRequest):
    """Generates a basic study plan based on subjects and hours"""
    plan = generate_study_plan(req.subjects, req.hours)
    return {"plan": plan}

@app.post("/ask")
def ask_ai(query: AskQuery):
    """Handles AI Q&A"""
    response = ask_learnflow(query.question)
    return {"response": response}

@app.post("/progress")
def mark_progress(data: dict):
    """Marks a topic as completed"""
    save_progress(data["username"], data["topic"])
    return {"message": "Progress saved"}

@app.get("/progress/{username}")
def fetch_progress(username: str):
    """Fetches the user's study progress"""
    return {"progress": get_progress(username)}

@app.post("/smart-schedule")
def smart_schedule(req: SmartScheduleRequest):
    """Generates a smart schedule based on preferences"""
    try:
        schedule = generate_smart_schedule(
            wake_time=req.wake_time,
            sleep_time=req.sleep_time,
            classes=req.classes,
            topics=req.topics,
            study_hours=req.study_hours,
            breaks=req.breaks
        )
        return {"schedule": schedule}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
