from fastapi import FastAPI
import socket
from datetime import datetime

app = FastAPI(
    title="cloud-app API",
    version="1.0.0",
)

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/transaction")
def transaction():
    return {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "hostname": socket.gethostname()
    }

@app.get("/tests")
def test():
    return {"message": "This is a test endpoint."}
