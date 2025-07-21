from datetime import datetime, timedelta

print("📦 smart_scheduler.py loaded")
# ... same for others


def generate_smart_schedule(wake_time: str, sleep_time: str, classes: list, topics: list, study_hours: int, breaks: int):
    """
    Generate a smart daily schedule that avoids class times and inserts study + break blocks.
    Times must be in 'HH:MM' 24-hr format.
    """
    def str_to_time(t): return datetime.strptime(t, "%H:%M")
    def time_to_str(t): return t.strftime("%H:%M")

    wake_dt = str_to_time(wake_time)
    sleep_dt = str_to_time(sleep_time)

    # Calculate total free time window
    total_minutes = int((sleep_dt - wake_dt).total_seconds() // 60)
    if total_minutes <= 0:
        return {"error": "Sleep time must be after wake time."}

    # Convert class times into datetime ranges
    class_blocks = []
    for c in classes:
        start, end = str_to_time(c["start"]), str_to_time(c["end"])
        class_blocks.append((start, end))

    # Sort class blocks
    class_blocks.sort()

    # Create free slots between wake_time and sleep_time avoiding class times
    current = wake_dt
    free_slots = []

    for start, end in class_blocks:
        if current < start:
            free_slots.append((current, start))
        current = max(current, end)

    # Add final free time before sleep
    if current < sleep_dt:
        free_slots.append((current, sleep_dt))

    # Estimate how many study blocks needed
    total_study_minutes = study_hours * 60
    break_count = max(breaks, 1)
    study_block_length = total_study_minutes // len(topics)

    schedule = []
    topic_index = 0

    for start, end in free_slots:
        slot_minutes = int((end - start).total_seconds() // 60)

        while slot_minutes >= study_block_length and topic_index < len(topics):
            study_start = start
            study_end = study_start + timedelta(minutes=study_block_length)

            schedule.append({
                "type": "study",
                "topic": topics[topic_index],
                "start": time_to_str(study_start),
                "end": time_to_str(study_end)
            })

            start = study_end
            slot_minutes -= study_block_length
            topic_index += 1

            # Add break if more topics are left
            if topic_index < len(topics):
                break_start = start
                break_end = break_start + timedelta(minutes=10)
                if break_end <= end:
                    schedule.append({
                        "type": "break",
                        "start": time_to_str(break_start),
                        "end": time_to_str(break_end)
                    })
                    start = break_end
                    slot_minutes -= 10
                else:
                    break  # Not enough time left for a break

    return schedule
