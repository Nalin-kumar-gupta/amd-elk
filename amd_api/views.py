import random
import json
import requests
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.exceptions import APIException
from amd_api.utils.es_client import get_es_client
from rest_framework.pagination import PageNumberPagination

class LogsAPIView(APIView):
    """
    API to fetch logs from Elasticsearch with pagination and navigation support.
    """
    class CustomPagination(PageNumberPagination):
        page_size = 10  # Default page size
        page_size_query_param = 'page_size'  # Allow clients to override page size
        max_page_size = 100  # Maximum page size

    pagination_class = CustomPagination

    def get(self, request, *args, **kwargs):
        es_client = get_es_client()
        paginator = self.pagination_class()

        try:
            # Get pagination parameters
            page = request.query_params.get(paginator.page_query_param, 1)
            page_size = paginator.get_page_size(request)

            # Calculate `from` value for Elasticsearch
            from_value = (int(page) - 1) * page_size

            # Refresh Elasticsearch index for near real-time updates
            es_client.indices.refresh(index="winlogbeat-*")

            # Elasticsearch query with sorting by latest timestamp
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

            # Extract logs from the response
            logs = [hit['_source'] for hit in response['hits']['hits']]
            total_logs = response['hits']['total']['value']

            # Generate pagination links
            paginated_data = paginator.paginate_queryset(logs, request)

            # Build response
            return paginator.get_paginated_response({
                "total_logs": total_logs,
                "logs": paginated_data
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
            # Query to aggregate unique machine names
            response = es_client.search(
                index="winlogbeat-*",  # Adjust this index pattern if needed
                body={
                    "aggs": {
                        "unique_machines": {
                            "terms": {
                                "field": "machine.name.keyword",  # Ensure this field is mapped correctly
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


