from typing import List, Optional

import httpx
from bson import ObjectId
from bson.errors import InvalidId
from fastapi import APIRouter, HTTPException, Depends

from ..data_management import Case, Customer, Vehicle, Workshop
from ..diagnostics_management import KnowledgeGraph
from ..security.token_auth import authorized_shared_access

tags_metadata = [
    {
        "name": "Shared",
        "description": "Read access to shared ressources"
    }
]


router = APIRouter(
    tags=["Shared"],
    dependencies=[Depends(authorized_shared_access)]
)


@router.get("/cases", status_code=200, response_model=List[Case])
async def list_cases(
        customer_id: str = None,
        vin: str = None,
        workshop_id: str = None
) -> List[Case]:
    """
    List all cases in Hub. Query params can be used to filter by `customer_id`,
    `vin` and `workshop_id`.
    """
    cases = await Case.find_in_hub(
        customer_id=customer_id, vin=vin, workshop_id=workshop_id
    )
    return cases


@router.get("/cases/{case_id}", status_code=200, response_model=Case)
async def get_case(case_id: str) -> Case:
    no_case_exception = HTTPException(
        status_code=404, detail=f"No case with id `{case_id}`"
    )
    try:
        case_id = ObjectId(case_id)
    except InvalidId:
        # invalid id reports not found to user
        raise no_case_exception

    case = await Case.get(case_id)
    if case is not None:
        return case
    else:
        raise no_case_exception


@router.get("/customers", status_code=200, response_model=List[Customer])
async def list_customers() -> List[Customer]:
    """
    List all customers in Hub.
    """
    customers = await Customer.find_all().to_list()
    return customers


@router.get(
    "/customers/{customer_id}", status_code=200, response_model=Customer
)
async def get_customer(customer_id: str) -> Customer:
    customer = await Customer.get(customer_id)
    if customer is not None:
        return customer
    else:
        exception_detail = f"No customer with id `{customer_id}`"
        raise HTTPException(status_code=404, detail=exception_detail)


@router.get("/vehicles", status_code=200, response_model=List[Vehicle])
async def list_vehicles() -> List[Vehicle]:
    """
    List all vehicles in Hub.
    """
    vehicles = await Vehicle.find_all().to_list()
    return vehicles


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


@router.get(
    "/known-components", status_code=200, response_model=List[str]
)
async def list_vehicle_components(
        kg_obd_url: Optional[str] = Depends(KnowledgeGraph.get_obd_url)
) -> List[str]:
    """List all vehicle component names known to the Hub's diagnostic
    backend.
    """
    if not kg_obd_url:
        # No knowledge graph configured
        return []
    components = get_components_from_knowledge_graph(kg_obd_url)
    return components


@router.get("/vehicles/{vin}", status_code=200, response_model=Vehicle)
async def get_vehicle(vin: str) -> Vehicle:
    vehicle = await Vehicle.find_one({"vin": vin})
    if vehicle is not None:
        return vehicle
    else:
        exception_detail = f"No vehicle with vin `{vin}`"
        raise HTTPException(status_code=404, detail=exception_detail)


@router.get("/workshops", status_code=200, response_model=List[Workshop])
async def list_workshops() -> List[Workshop]:
    """
    Get all workshops in Hub.
    """
    workshops = await Workshop.find_all().to_list()
    return workshops


@router.get(
    "/workshops/{workshop_id}", status_code=200, response_model=Workshop
)
async def get_workshop(workshop_id: str) -> Workshop:
    workshop = await Workshop.get(workshop_id)
    if workshop is not None:
        return workshop
    else:
        exception_detail = f"No workshop with id `{workshop_id}`"
        raise HTTPException(status_code=404, detail=exception_detail)
