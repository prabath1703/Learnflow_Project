# planner.py

import logging
from ml_schedule_generator import generate_schedule

print("📦 planner.py loaded")

# ✅ Visionary AI-based schedule
def generate_visionary_schedule(prompt: str):
    """
    Generates a visionary AI-powered schedule using the fine-tuned T5 model.

    Args:
        prompt (str): User prompt describing goals or focus.

    Returns:
        dict: {
            "schedule": list of dicts,
            "used_fallback": bool
        }
    """
    schedule = generate_schedule(prompt)

    # Check for fallback pattern (optional, can be removed if fallback is disabled)
    used_fallback = any(
        isinstance(block, dict) and
        block.get("Subject") == "Self-Prep" and
        block.get("Time") == "06:00–07:00"
        for block in schedule
    )

    return {
        "schedule": schedule,
        "used_fallback": used_fallback
    }
