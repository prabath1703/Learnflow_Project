from dotenv import load_dotenv
load_dotenv()
import re
import os
import io
import openai
import PyPDF2
from fastapi import FastAPI, HTTPException, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
from youtube_transcript_api import YouTubeTranscriptApi
from models import VisionaryScheduleRequest
from planner import generate_visionary_schedule

# ✅ Start message
print("✅ LearnFlow backend is starting...")

# ✅ OpenAI API Key
openai.api_key = os.getenv("OPENAI_API_KEY")
if not openai.api_key:
    raise ValueError("❌ No OpenAI API key found. Set OPENAI_API_KEY in .env file.")
print(f"🔑 OpenAI key found: {bool(openai.api_key)}")

# ✅ FastAPI instance
app = FastAPI(title="LearnFlow API")

# ✅ Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # ⚠️ Change in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"message": "Welcome to LearnFlow API"}

# Visionary Schedule Generator
@app.post("/generate-visionary-schedule")
def generate_visionary_schedule_route(request: VisionaryScheduleRequest):
    try:
        result = generate_visionary_schedule(request.prompt)
        return {
            "generated_schedule": result["schedule"],
            "used_fallback": result["used_fallback"]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# AI Summarizer: YouTube
@app.post("/summarize-youtube")
def summarize_youtube(url: str = Form(...)):
    try:
        # ✅ Robust YouTube video ID extraction
        match = re.search(
            r'(?:v=|\/)([0-9A-Za-z_-]{11})',
            url
        )
        if not match:
            # Try youtu.be short link format
            match = re.search(r'youtu\.be\/([0-9A-Za-z_-]{11})', url)
        if not match:
            raise HTTPException(status_code=400, detail="Invalid YouTube URL format")

        video_id = match.group(1)

        # ✅ Fetch transcript
        transcript = YouTubeTranscriptApi.get_transcript(video_id)

        full_text = " ".join([t["text"] for t in transcript])

        return generate_learning_package(full_text)

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing YouTube video: {str(e)}")

# AI Summarizer: PDFs
@app.post("/summarize-pdf")
async def summarize_pdf(file: UploadFile):
    try:
        pdf_reader = PyPDF2.PdfReader(io.BytesIO(await file.read()))
        text = " ".join(
            [page.extract_text() for page in pdf_reader.pages if page.extract_text()]
        )
        return generate_learning_package(text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing PDF: {str(e)}")

# ---------- AI Helper Functions ----------

def generate_learning_package(text: str):
    return {
        "summary": generate_summary(text),
        "flashcards": generate_flashcards(text),
        "quiz": generate_quiz(text)
    }

def generate_summary(text: str):
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{
            "role": "user",
            "content": f"Summarize this content into concise, clear study notes:\n{text}"
        }],
        max_tokens=500
    )
    return response.choices[0].message["content"]

def generate_flashcards(text: str):
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{
            "role": "user",
            "content": f"Create 10 Q&A flashcards from this study content:\n{text}"
        }],
        max_tokens=500
    )
    return response.choices[0].message["content"]

def generate_quiz(text: str):
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{
            "role": "user",
            "content": f"Generate 5 multiple-choice quiz questions with answers from this content:\n{text}"
        }],
        max_tokens=500
    )
    return response.choices[0].message["content"]
