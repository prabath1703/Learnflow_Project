from pydantic import BaseModel
from typing import List, Optional

class User(BaseModel):
    username: str
    password: str

class StudyRequest(BaseModel):
    username: str
    subjects: List[str]
    hours: int

class AskQuery(BaseModel):
    username: str
    question: str

# ✅ NEW: Smart Schedule Request model
class SmartScheduleRequest(BaseModel):
    username: str
    wake_up_time: str        # Format: "07:00"
    sleep_time: str          # Format: "23:00"
    class_times: List[str]   # Example: ["10:00-11:00", "15:00-16:00"]
    topics: List[str]        # Topics to study
    study_hours: int         # Total desired study hours per day
    break_minutes: Optional[int] = 10  # Default break time
