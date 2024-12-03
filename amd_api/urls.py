from django.urls import path
from .views import LogsAPIView, MachinesAPIView

urlpatterns = [
    path('logs/<str:hostname>/', LogsAPIView.as_view(), name='get_logs'),
    path('raw_logs/', LogsAPIView.as_view(), name='get_logs'),
    path('machines/', MachinesAPIView.as_view(), name='get_machines'),
]
