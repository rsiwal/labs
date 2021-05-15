from flask import Flask
import os
import socket

app = Flask(__name__)
@app.route("/")

def hello():
    html = "<h3 style='color:{color};'>I am {color}</h3>"
    return html.format(color=os.getenv("COLOR"))

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
