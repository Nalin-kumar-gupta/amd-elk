from django.urls import path
from .views import LogsAPIView, MachinesAPIView

urlpatterns = [
    path('logs/', LogsAPIView.as_view(), name='get_logs'),
    path('machines/', MachinesAPIView.as_view(), name='get_machines'),
]
