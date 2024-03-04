from typing import List, Optional

from fastapi import APIRouter, Depends

from ..diagnostics_management import (
    KnowledgeGraph, get_components_from_knowledge_graph
)
from ..security.token_auth import authorized_knowledge_access

tags_metadata = [
    {
        "name": "Knowledge",
        "description": "Read access to information stored in the connected "
                       "knowledge graph."
    }
]


router = APIRouter(
    tags=["Knowledge"],
    dependencies=[Depends(authorized_knowledge_access)]
)


@router.get("/components", response_model=list[str], status_code=200)
async def list_vehicle_components(
        kg_obd_url: Optional[str] = Depends(KnowledgeGraph.get_obd_url)
) -> List[str]:
    """List all names of vehicle components stored in the knowledge graph
    instance connected to the Hub.
    """
    if not kg_obd_url:
        # No knowledge graph configured
        return []
    components = get_components_from_knowledge_graph(kg_obd_url)
    return components
