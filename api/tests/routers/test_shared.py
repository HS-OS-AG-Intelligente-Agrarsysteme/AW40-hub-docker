import httpx
import pytest
from api.diagnostics_management import KnowledgeGraph
from api.routers import shared
from fastapi import FastAPI
from fastapi.testclient import TestClient


@pytest.fixture
def test_app():
    app = FastAPI()
    app.include_router(shared.router)
    return app


@pytest.fixture
def test_client(test_app):
    return TestClient(test_app)


def test_list_vehicle_components_no_kg_configured(test_client):
    KnowledgeGraph.set_kg_url(None)
    response = test_client.get("/known-components")
    assert response.status_code == 200
    assert response.json() == []


def test_list_vehicle_components_kg_not_available(test_client):
    KnowledgeGraph.set_kg_url("http://no-kg-hosted-here:4242")
    response = test_client.get("/known-components")
    assert response.status_code == 200
    assert response.json() == []


@pytest.fixture
def kg_url():
    """Assume local fuseki server is available at 3030"""
    return "http://127.0.0.1:3030"


@pytest.fixture()
def obd_dataset_name():
    return "OBDpytest"


@pytest.fixture
def prefilled_knowledge_graph(
        kg_url, obd_dataset_name, knowledge_graph_file
):
    # create a fresh dataset for testing
    httpx.post(
        url=f"{kg_url}/$/datasets",
        data={
            "dbType": "mem",
            "dbName": f"/{obd_dataset_name}",
        }
    )
    # load content from knowledge_graph_file fixture into the test dataset
    httpx.put(
        url=f"{kg_url}/{obd_dataset_name}",
        content=knowledge_graph_file,
        headers={"Content-Type": "text/turtle"}
    )
    yield
    # remove the dataset after testing
    httpx.delete(url=f"{kg_url}/$/datasets/{obd_dataset_name}")


def test_list_vehicle_components(
        test_app, test_client, kg_url, obd_dataset_name,
        prefilled_knowledge_graph
):
    # point the endpoint dependency to the test dataset
    KnowledgeGraph.set_kg_url(kg_url)
    KnowledgeGraph.obd_dataset_name = obd_dataset_name
    # test
    response = test_client.get("/known-components")
    assert response.status_code == 200
    assert response.json() == [
        "boost_pressure_control_valve", "boost_pressure_solenoid_valve"
    ]
