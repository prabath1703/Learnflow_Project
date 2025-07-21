import json

DATA_FILE = "db.json"

def load_db():
    try:
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    except:
        return {}

def save_db(data):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=4)

def save_progress(username, topic):
    db = load_db()
    if username not in db:
        db[username] = []
    db[username].append(topic)
    save_db(db)

def get_progress(username):
    db = load_db()
    return db.get(username, [])
