from flask import Flask, request, jsonify
from planner.generator import generate_learning_plan

app = Flask(__name__)

@app.route('/generate-plan', methods=['POST'])
def generate_plan():
    data = request.get_json()
    topic = data.get("topic", "General")
    plan = generate_learning_plan(topic)
    return jsonify({"topic": topic, "plan": plan})

if __name__ == '__main__':
    app.run(debug=True)
