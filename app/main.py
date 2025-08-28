from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/")
def hello():
    return jsonify(message="Hello from DevOps pipeline!"), 200

@app.get("/health")
def health():
    return "ok", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
