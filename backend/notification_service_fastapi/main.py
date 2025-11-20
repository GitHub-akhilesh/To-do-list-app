from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
from datetime import datetime

app = FastAPI(title="Notification Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Notification(BaseModel):
    id: int
    message: str
    created_at: datetime

_notifications: List[Notification] = []

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/notifications", response_model=List[Notification])
def list_notifications():
    return _notifications

@app.post("/notifications", response_model=Notification)
def create_notification(n: Notification):
    _notifications.append(n)
    return n
