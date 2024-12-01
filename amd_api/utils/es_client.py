from elasticsearch import Elasticsearch

def get_es_client():
    """
    Returns an Elasticsearch client instance.
    """
    return Elasticsearch(['http://elasticsearch:9200'])  # Update with your ES configuration