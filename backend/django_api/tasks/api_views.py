from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from . import db

class TaskListCreate(APIView):
    def get(self, request):
        tasks = db.list_tasks()
        return Response(tasks)

    def post(self, request):
        payload = request.data or {}
        if not payload.get("title"):
            return Response({"detail": "title is required"}, status=status.HTTP_400_BAD_REQUEST)
        task = db.create_task(payload)
        return Response(task, status=status.HTTP_201_CREATED)

class TaskDetail(APIView):
    def get(self, request, task_id):
        task = db.get_task(task_id)
        if not task:
            return Response({"detail": "Not found"}, status=status.HTTP_404_NOT_FOUND)
        return Response(task)

    def put(self, request, task_id):
        if not db.get_task(task_id):
            return Response({"detail": "Not found"}, status=status.HTTP_404_NOT_FOUND)
        payload = request.data or {}
        if not payload.get("title"):
            return Response({"detail": "title is required"}, status=status.HTTP_400_BAD_REQUEST)
        task = db.update_task(task_id, payload)
        return Response(task)

    def delete(self, request, task_id):
        ok = db.delete_task(task_id)
        if not ok:
            return Response({"detail": "Not found"}, status=status.HTTP_404_NOT_FOUND)
        return Response(status=status.HTTP_204_NO_CONTENT)
