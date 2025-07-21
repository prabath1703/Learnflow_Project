import openai
import os

openai.api_key = os.getenv("OPENAI_API_KEY")
print("📦 smart_scheduler.py loaded")
# ... same for others


def ask_learnflow(question):
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "You're a helpful study assistant."},
            {"role": "user", "content": question}
        ]
    )
    return response['choices'][0]['message']['content']
