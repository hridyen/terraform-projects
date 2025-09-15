from flask import Flask, request, render_template_string
import boto3
import os

app = Flask(__name__)

# configure your S3
s3 = boto3.client('s3')
BUCKET_NAME = "hriday-image-uploads"   # change if needed

# HTML form
UPLOAD_FORM = """
<!doctype html>
<title>Upload to S3</title>
<h1>Upload new File</h1>
<form method=post enctype=multipart/form-data action="/upload">
  <input type=file name=file>
  <input type=submit value=Upload>
</form>
"""

@app.route("/")
def index():
    return render_template_string(UPLOAD_FORM)

@app.route("/upload", methods=["POST"])
def upload_file():
    if "file" not in request.files:
        return "No file part"
    file = request.files["file"]
    if file.filename == "":
        return "No selected file"
    
    s3.upload_fileobj(file, BUCKET_NAME, file.filename)
    return f"Uploaded {file.filename} to S3 bucket {BUCKET_NAME}!"

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
