from django.urls import path
from . import api_views

urlpatterns = [
    path("tasks/", api_views.TaskListCreate.as_view(), name="task-list-create"),
    path("tasks/<int:task_id>/", api_views.TaskDetail.as_view(), name="task-detail"),
]
