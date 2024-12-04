from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.exceptions import APIException
from amd_api.utils.es_client import get_es_client
from rest_framework.pagination import PageNumberPagination
import random
from datetime import datetime


class RawLogsAPIView(APIView, PageNumberPagination):
    """
    API to fetch logs from Elasticsearch with pagination.
    """
    page_size = 50  # Default page size
    page_size_query_param = 'page_size'  # Allow clients to override the page size
    max_page_size = 100  # Maximum page size

    def get(self, request, *args, **kwargs):
        es_client = get_es_client()
        try:
            # Get pagination parameters
            page = request.query_params.get('page', 1)  # Default to the first page
            page_size = self.get_page_size(request)

            # Calculate `from` based on the page and page size
            from_value = (int(page) - 1) * page_size

            # Refresh Elasticsearch index for near real-time results
            es_client.indices.refresh(index="winlogbeat-*")

            # Elasticsearch query with pagination and sorting by latest timestamp
            response = es_client.search(
                index="winlogbeat-*",
                body={
                    "query": {
                        "match_all": {}
                    },
                    "from": from_value,
                    "size": page_size,
                    "sort": [{"@timestamp": {"order": "desc"}}],  # Latest logs on top
                }
            )

            # Extract logs from response
            logs = [hit['_source'] for hit in response['hits']['hits']]
            total_logs = response['hits']['total']['value']  # Total number of logs

            # Build paginated response
            return Response({
                "status": "success",
                "page": int(page),
                "page_size": page_size,
                "total_logs": total_logs,
                "data": logs
            })

        except Exception as e:
            raise APIException(detail=f"Error fetching logs: {str(e)}")



# API View for Logs with Risk Level
class LogsAPIView(APIView, PageNumberPagination):
    """
    API to fetch logs from Elasticsearch with pagination and hostname-based filtering.
    """
    page_size = 10  # Default page size
    page_size_query_param = 'page_size'  # Allow clients to override the page size
    max_page_size = 100  # Maximum page size

    def _get_risk_level(self, log):
        # {
        #     "hostname": "DELL-42",
        #     "timestamp": "2024-12-04T07:28:32.480Z",
        #     "user": "SYSTEM",
        #     "process_name": "C:\\Users\\vboxuser\\AppData\\Local\\Programs\\Python\\Python313\\python.exe",
        #     "command_line": "\"C:\\Users\\vboxuser\\AppData\\Local\\Programs\\Python\\Python313\\python.exe\" .\\runner.py",
        #     "description": "Python",
        #     "action": "CreateRemoteThread detected (rule: CreateRemoteThread)",
        #     "risk_level": "Medium"
        # },
        # {
        #     "hostname": "DELL-42",
        #     "timestamp": "2024-12-04T07:28:29.481Z",
        #     "user": "SYSTEM",
        #     "process_name": "C:\\Users\\vboxuser\\AppData\\Local\\Programs\\Python\\Python313\\python.exe",
        #     "command_line": "Unknown",
        #     "description": "Unknown",
        #     "action": "CreateRemoteThread detected (rule: CreateRemoteThread)",
        #     "risk_level": "Low"
        # },

        # hostname = log.get("host", {}).get("hostname", "Unknown")
        # timestamp = log.get("@timestamp", "N/A")
        # user = log.get("winlog", {}).get("user", {}).get("name", "Unknown"), 
        process_name = (
                        log.get("winlog", {}).get("event_data", {}).get("Image") or
                        log.get("winlog", {}).get("event_data", {}).get("ProcessName") or
                        next(iter(log.get("winlog", {}).get("event_data", {}).values()), "Unknown")
                    ) 
        # command_line = log.get("winlog", {}).get("event_data", {}).get("CommandLine", "Unknown"), 
        # description = log.get("winlog", {}).get("event_data", {}).get("Description", "Unknown"),
        # action = log.get("event", {}).get("action", "unknown"),
        choices = ["Low", "Medium"] 
        weights = [1, 0]
        if process_name.endswith("python.exe"):
            return "High"
        elif process_name.endswith("msedge.exe"):
            weights = [0.5, 0.5]
        else:
            weights = [0.8, 0.2]  

        return random.choices(choices, weights=weights, k=1)[0] 

    def get(self, request, hostname, *args, **kwargs):
        es_client = get_es_client()
        try:
            # Get pagination parameters
            page = request.query_params.get('page', 1)  # Default to the first page
            page_size = self.get_page_size(request)

            # Calculate `from` based on the page and page size
            from_value = (int(page) - 1) * page_size

            # Refresh Elasticsearch index for near real-time results
            es_client.indices.refresh(index="winlogbeat-*")

            # Elasticsearch query with hostname filtering, pagination, and sorting
            response = es_client.search(
                index="winlogbeat-*",
                body={
                    "query": {
                        "bool": {
                            "must": [
                                {"match": {"host.hostname": hostname}}
                            ]
                        }
                    },
                    "from": from_value,
                    "size": page_size,
                    "sort": [{"@timestamp": {"order": "desc"}}],  # Latest logs on top
                }
            )

            # Extract logs from response
            logs = [hit['_source'] for hit in response['hits']['hits']]
            total_logs = response['hits']['total']['value']  # Total number of logs

            # Clean up the logs and add a fake risk level
            cleaned_logs = []
            for log in logs:
                cleaned_log = {
                    "hostname": log.get("host", {}).get("hostname", "Unknown"),
                    "timestamp": log.get("@timestamp", "N/A"),
                    "user": log.get("winlog", {}).get("user", {}).get("name", "Unknown"),
                    "process_name": (
                        log.get("winlog", {}).get("event_data", {}).get("Image") or
                        log.get("winlog", {}).get("event_data", {}).get("ProcessName") or
                        next(iter(log.get("winlog", {}).get("event_data", {}).values()), "Unknown")
                    ),
                    "command_line": log.get("winlog", {}).get("event_data", {}).get("CommandLine", "Unknown"),
                    "description": log.get("winlog", {}).get("event_data", {}).get("Description", "Unknown"),
                    "action": log.get("event", {}).get("action", "unknown"),
                    "risk_level": self._get_risk_level(log),  # Random risk level
                }

                # Save cleaned logs to a new index pattern (e.g., "sysmon-logs-risk")
                es_client.index(index="sysmon-logs-risk", body=cleaned_log)
                cleaned_logs.append(cleaned_log)

            # Build paginated response
            return Response({
                "status": "success",
                "page": int(page),
                "page_size": page_size,
                "total_logs": total_logs,
                "data": cleaned_logs,
            })

        except Exception as e:
            raise APIException(detail=f"Error fetching logs: {str(e)}")


class MachinesAPIView(APIView):
    """
    API to fetch unique machine details (host names) from Elasticsearch.
    """
    def get(self, request, *args, **kwargs):
        es_client = get_es_client()
        try:
            # Query to aggregate unique machine names based on the host.hostname field
            response = es_client.search(
                index="winlogbeat-*",  # Adjust this index pattern if needed
                body={
                    "aggs": {
                        "unique_machines": {
                            "terms": {
                                "field": "host.hostname.keyword",  # Ensure this field is mapped correctly
                                "size": 1000  # Increase the size if needed for more unique machine names
                            }
                        }
                    },
                    "size": 0  # We don't need the individual documents, just the aggregation
                }
            )

            # Extract unique machine names from the aggregation response
            machines = [bucket['key'] for bucket in response['aggregations']['unique_machines']['buckets']]

            return Response({"status": "success", "data": machines})

        except Exception as e:
            # Return an error message if there's an exception
            raise APIException(detail=f"Error fetching unique machines: {str(e)}")



