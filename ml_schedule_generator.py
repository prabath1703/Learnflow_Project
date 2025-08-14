from transformers import T5Tokenizer, T5ForConditionalGeneration
import torch
import logging
import re
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Hugging Face model repo
model_name = "PrabathDamarla/visionary_schedule_model"

try:
    logger.info(f"⏳ Loading visionary model from Hugging Face: {model_name}")
    tokenizer = T5Tokenizer.from_pretrained(model_name)
    model = T5ForConditionalGeneration.from_pretrained(model_name)
    model_loaded = True
    logger.info("✅ Visionary model loaded successfully from Hugging Face.")
except Exception as e:
    logger.error(f"❌ Failed to load T5 model from Hugging Face: {e}")
    model_loaded = False


def beautify_schedule(raw_output):
    today = datetime.now()
    formatted_date = today.strftime("%B %d")  # Example: August 13

    raw_output = raw_output.replace("Visionary Schedule", "").strip()

    blocks = re.findall(
        r"(\d{2}:\d{2}–\d{2}:\d{2})\s*–\s*(.*?)(?=(?:\d{2}:\d{2}–\d{2}:\d{2})|$)",
        raw_output
    )

    emoji_map = {
        "Morning Routine": "☀️", "Physics": "⚛️", "Science": "🔬", "Chemistry": "🧪",
        "Biology": "🧬", "Math": "📐", "Breakfast": "🍽️", "Lunch": "🥗", "Dinner": "🍽️",
        "Snacks": "🍪", "Nap": "🛏️", "Sleep": "😴", "Sleep Prep": "😴", "Break": "☕",
        "Tea Break": "🍵", "Relax": "🧘", "Meditation": "🧘‍♂️", "Exercise": "🏋️‍♀️",
        "Light Walk": "🚶", "Walk": "🚶‍♂️", "Mock Test": "📝", "Doubt Solving": "❓",
        "Revision": "🔁", "Final Review": "✅", "Reading": "📖", "Journaling": "📓",
        "Mindfulness": "🧠", "YouTube": "📺", "Instagram": "📸", "Pomodoro": "🍅",
        "Productivity": "💡", "Focus": "🎯", "Call": "📞", "Meeting": "📅"
    }

    clock_emojis = ["🕖", "🕗", "🕘", "🕙", "🕚", "🕛", "🕐", "🕑", "🕒", "🕓", "🕔", "🕕"]

    formatted = [f"📅 {formatted_date} — Visionary Schedule"]
    for i, (time, task) in enumerate(blocks):
        emoji = next((emoji_map[key] for key in emoji_map if key.lower() in task.lower()), "")
        clock = clock_emojis[i % len(clock_emojis)]
        formatted.append(f"{clock} {time} – {task.strip()} {emoji}")

    return "\n".join(formatted)


def generate_schedule(prompt_text):
    if not model_loaded:
        return "❌ Visionary model not loaded."

    try:
        input_text = f"Generate schedule: {prompt_text}"
        inputs = tokenizer(input_text, return_tensors="pt").to(model.device)

        outputs = model.generate(
            **inputs,
            max_new_tokens=300,
            do_sample=True,
            top_k=50,
            top_p=0.95,
            temperature=0.9,
            repetition_penalty=1.2,
            num_beams=1,
        )

        raw_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
        print(raw_text)

        return beautify_schedule(raw_text)

    except Exception as e:
        logger.error(f"❌ Exception during generation: {e}")
        return "❌ Error generating schedule."
