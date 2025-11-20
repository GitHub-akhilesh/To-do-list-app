import json
from django.test import Client
from tasks.db import init_db

def setup_module(module):
    init_db()

client = Client()

def test_create_and_list_tasks():
    payload = {"title": "Test task from pytest"}
    resp = client.post("/api/tasks/", data=json.dumps(payload), content_type="application/json")
    assert resp.status_code == 201
    data = resp.json()
    assert data["title"] == "Test task from pytest"

    resp = client.get("/api/tasks/")
    assert resp.status_code == 200
    assert any(t["title"] == "Test task from pytest" for t in resp.json())
