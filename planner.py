import random
from datetime import datetime, timedelta

print("📦 smart_scheduler.py loaded")
# ... same for others


def generate_study_plan(subjects, total_hours):
    plan = {}
    hours_per_subject = total_hours // len(subjects)
    for subject in subjects:
        plan[subject] = f"{hours_per_subject} hrs"
    leftover = total_hours % len(subjects)
    if leftover:
        plan[subjects[0]] = f"{hours_per_subject + leftover} hrs"
    return plan

# ✅ NEW: Smart daily scheduler
def generate_smart_schedule(wake_up_time, sleep_time, class_times, topics, study_hours, break_minutes=10):
    def str_to_time(s):
        return datetime.strptime(s, "%H:%M")

    def time_to_str(t):
        return t.strftime("%H:%M")

    # Parse times
    wake = str_to_time(wake_up_time)
    sleep = str_to_time(sleep_time)
    total_day_minutes = int((sleep - wake).total_seconds() / 60)

    # Parse class blocks
    class_blocks = []
    for ct in class_times:
        start, end = ct.split("-")
        class_blocks.append((str_to_time(start), str_to_time(end)))

    # Build available time slots (excluding class times)
    current = wake
    free_blocks = []

    for start, end in sorted(class_blocks):
        if current < start:
            free_blocks.append((current, start))
        current = max(current, end)
    if current < sleep:
        free_blocks.append((current, sleep))

    # Assign study sessions
    study_plan = []
    topic_queue = topics * ((study_hours + len(topics) - 1) // len(topics))
    topic_index = 0
    remaining_study_minutes = study_hours * 60

    for block_start, block_end in free_blocks:
        block_duration = int((block_end - block_start).total_seconds() / 60)
        cursor = block_start

        while remaining_study_minutes > 0 and (block_end - cursor).total_seconds() >= 30 * 60:
            session_duration = min(60, remaining_study_minutes)  # 1 hr max per session
            end_time = cursor + timedelta(minutes=session_duration)
            study_plan.append({
                "topic": topic_queue[topic_index % len(topics)],
                "start": time_to_str(cursor),
                "end": time_to_str(end_time)
            })
            cursor = end_time + timedelta(minutes=break_minutes)
            remaining_study_minutes -= session_duration
            topic_index += 1

            if cursor >= block_end:
                break

    return study_plan
