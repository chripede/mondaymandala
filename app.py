from flask import Flask, render_template, request, jsonify
import subprocess
import os

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/print", methods=["POST"])
def print_pdf():
    url = request.json.get("url", "").strip()
    if not url.startswith("https://"):
        return jsonify({"error": "Ugyldig URL — skal starte med https://"}), 400

    result = subprocess.run(
        ["./mondaymandala.sh", url],
        capture_output=True,
        text=True,
        env={**os.environ}
    )

    if result.returncode != 0:
        return jsonify({"error": result.stderr or "Ukendt fejl"}), 500

    return jsonify({"ok": True})
