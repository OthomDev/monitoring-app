from flask import Flask, render_template
import psutil

app = Flask(__name__)

@app.route('/')
def home():
    return render_template("home.html")

@app.route('/metrics')
def metrics():
    cpu_usage = psutil.cpu_percent(interval=1)
    memory_info = psutil.virtual_memory()
    disk_usage = psutil.disk_usage('/')

    return render_template(
        "metrics.html",
        cpu_usage=cpu_usage,
        memory_usage=memory_info.percent,
        disk_usage=disk_usage.percent
    )

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=4000, debug=True)
