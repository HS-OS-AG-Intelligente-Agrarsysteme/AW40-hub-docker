from api.diagnostics_management.knowledge_retrieval import (
    get_components_from_knowledge_graph
)
import pytest


@pytest.mark.asyncio
async def test_list_vehicle_components(
        kg_url, kg_obd_dataset_name, kg_components, kg_prefilled
):
    retrieved_components = get_components_from_knowledge_graph(
        f"{kg_url}/{kg_obd_dataset_name}"
    )
    assert sorted(retrieved_components) == sorted(kg_components)


@pytest.mark.asyncio
async def test_list_vehicle_components_invalid_kg_in_url(kg_obd_dataset_name):
    retrieved_components = get_components_from_knowledge_graph(
        f"http://no-kg-hosted-here:4242/{kg_obd_dataset_name}"
    )
    assert retrieved_components == []


@pytest.mark.asyncio
async def test_list_vehicle_components_invalid_dataset_in_url(kg_url):
    retrieved_components = get_components_from_knowledge_graph(
        f"{kg_url}/no-dataset-here"
    )
    assert retrieved_components == []
