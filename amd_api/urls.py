from django.urls import path
from .views import LogsAPIView, MachinesAPIView, RawLogsAPIView

urlpatterns = [
    path('logs/<str:hostname>/', LogsAPIView.as_view(), name='get_logs'),
    path('raw_logs/', RawLogsAPIView.as_view(), name='get_logs'),
    path('machines/', MachinesAPIView.as_view(), name='get_machines'),
]
