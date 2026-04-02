from flask import Flask, request, jsonify, send_from_directory
import subprocess
import os
import json

app = Flask(__name__, static_folder="static")

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/")
def serve_index():
    return send_from_directory("static", "index.html")


@app.route("/run", methods=["POST"])
def run_analysis():
    try:
        # Get uploaded files
        eRNA_file = request.files["eRNA"]
        frac_file = request.files["frac"]
        type_file = request.files["type"]

        # Save files
        eRNA_path = os.path.join(UPLOAD_FOLDER, "eRNA.rds")
        frac_path = os.path.join(UPLOAD_FOLDER, "frac.rds")
        type_path = os.path.join(UPLOAD_FOLDER, "type.rds")

        eRNA_file.save(eRNA_path)
        frac_file.save(frac_path)
        type_file.save(type_path)

        # Run R script
        result = subprocess.run(
            ["Rscript", "example_function.r", eRNA_path, frac_path, type_path],
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            return jsonify({"error": result.stderr}), 500

        # Parse JSON output from R
        rec = json.loads(result.stdout)

        return jsonify(rec)

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True)
