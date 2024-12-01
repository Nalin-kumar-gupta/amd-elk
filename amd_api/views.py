import random
import json
import requests
from faker import Faker
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.exceptions import APIException
from amd_api.utils.es_client import get_es_client

fake = Faker()

class LogsAPIView(APIView):
    """
    API to fetch logs from Elasticsearch.
    """
    def get(self, request, *args, **kwargs):
        es_client = get_es_client()
        try:
            response = es_client.search(
                index="winlogbeat-*",
                body={
                    "query": {
                        "match_all": {}
                    },
                    "size": 100,
                    "sort": [{"@timestamp": {"order": "desc"}}],
                }
            )
            logs = [hit['_source'] for hit in response['hits']['hits']]
            return Response({"status": "success", "data": logs})
        except Exception as e:
            raise APIException(detail=str(e))

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


