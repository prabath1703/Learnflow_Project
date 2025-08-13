from transformers import T5Tokenizer, T5ForConditionalGeneration
import torch
import os
import logging
import re
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

model_path = os.path.join("ml_models", "visionary_schedule_model")

try:
    tokenizer = T5Tokenizer.from_pretrained(model_path)
    model = T5ForConditionalGeneration.from_pretrained(model_path)
    model_loaded = True
    logger.info("✅ Visionary model loaded successfully.")
except Exception as e:
    logger.error(f"❌ Failed to load T5 model: {e}")
    model_loaded = False


def beautify_schedule(raw_output):
    today = datetime.now()
    formatted_date = today.strftime("%B %d")  # Example: August 08

    # Remove the leading label if it exists
    raw_output = raw_output.replace("Visionary Schedule", "").strip()

    # Extract time-task pairs
    blocks = re.findall(
        r"(\d{2}:\d{2}–\d{2}:\d{2})\s*–\s*(.*?)(?=(?:\d{2}:\d{2}–\d{2}:\d{2})|$)",
        raw_output
    )

    # Emoji map (EXTENDED)
    emoji_map = {
        "Morning Routine": "☀️",
        "Physics": "⚛️",
        "Science": "🔬",
        "Chemistry": "🧪",
        "Biology": "🧬",
        "Math": "📐",
        "Breakfast": "🍽️",
        "Lunch": "🥗",
        "Dinner": "🍽️",
        "Snacks": "🍪",
        "Nap": "🛏️",
        "Sleep": "😴",
        "Sleep Prep": "😴",
        "Break": "☕",
        "Tea Break": "🍵",
        "Relax": "🧘",
        "Meditation": "🧘‍♂️",
        "Exercise": "🏋️‍♀️",
        "Light Walk": "🚶",
        "Walk": "🚶‍♂️",
        "Mock Test": "📝",
        "Doubt Solving": "❓",
        "Revision": "🔁",
        "Final Review": "✅",
        "Reading": "📖",
        "Journaling": "📓",
        "Mindfulness": "🧠",
        "YouTube": "📺",
        "Instagram": "📸",
        "Pomodoro": "🍅",
        "Productivity": "💡",
        "Focus": "🎯",
        "Call": "📞",
        "Meeting": "📅"
    }

    # Clock emojis for time blocks
    clock_emojis = ["🕖", "🕗", "🕘", "🕙", "🕚", "🕛", "🕐", "🕑", "🕒", "🕓", "🕔", "🕕"]

    # Add date to the top header
    formatted = [f"📅 {formatted_date} — Visionary Schedule"]
    for i, (time, task) in enumerate(blocks):
        emoji = ""
        for key in emoji_map:
            if key.lower() in task.lower():
                emoji = emoji_map[key]
                break
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
