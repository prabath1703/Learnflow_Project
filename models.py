from pydantic import BaseModel
from typing import List

# For /register
class User(BaseModel):
    username: str
    email: str = None

# For /plan
class StudyRequest(BaseModel):
    subjects: List[str]
    hours: int

# For /ask
class AskQuery(BaseModel):
    question: str

# For /smart-schedule
class ClassTime(BaseModel):
    day: str
    start: str
    end: str

class SmartScheduleRequest(BaseModel):
    username: str
    wake_up_time: str
    sleep_time: str
    class_times: List[ClassTime]
    topics: List[str]
    study_hours: int
    breaks: int
