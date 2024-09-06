import httpx
from typing import List


def get_components_from_knowledge_graph(kg_obd_url: str) -> List[str]:
    """Try to fetch all vehicle component names stored in knowledge graph.

    Returned list will be empty, if retrieval fails.
    """
    # construct sparql endpoint and query
    sparql_endpoint = f"{kg_obd_url}/sparql"
    ontology_prefix = "<http://www.semanticweb.org/diag_ontology#>"
    component_ontology_entry = ontology_prefix.replace(
        "#", "#SuspectComponent"
    )
    name_ontology_entry = ontology_prefix.replace("#", "#component_name")
    sparql_query = f"SELECT ?name WHERE {{?comp a {component_ontology_entry}" \
                   f" . ?comp {name_ontology_entry} ?name .}}"
    # try to send sparql query via knowledge graphs http interface
    try:
        response = httpx.post(
            sparql_endpoint,
            content=sparql_query.encode(),
            headers={
                'Content-Type': 'application/sparql-query',
                'Accept': 'application/json'
            }
        )
        response.raise_for_status()
    except (
            httpx.ConnectError, httpx.ConnectTimeout, httpx.HTTPStatusError
    ) as e:
        print("Failed to fetch data from knowledge graph with")
        print(type(e).__name__, ":", e)
        return []

    # try to extract components from response
    try:
        response_data = response.json()
        bindings = response_data["results"]["bindings"]
        components = [binding["name"]["value"] for binding in bindings]
        return components
    except KeyError as e:
        print("Failed to process data fetched from knowledge graph with")
        print(type(e).__name__, ":", e)
        return []
