import uuid
import pytest
from httpx import Client
from api.routers import minio
from fastapi import FastAPI
from fastapi.testclient import TestClient

# Test run again the api container. Use the api key configured for the api's
# minio router in dev.env
client = Client(headers={"x-api-key": "minio-key-dev"})

base_addr = "http://localhost:8000/v1/minio"
bucket = "werkstatthub"


def test_upload():
    global testval
    testval = str(uuid.uuid4())
    response = client.put(
        f"{base_addr}/{bucket}/test1.txt",
        content=testval,
        headers={'Content-Type': 'text/plain'})
    assert response.status_code == 200


def test_download():
    response = client.get(
        f"{base_addr}/{bucket}/test1.txt")
    assert response.status_code == 200
    assert response.text == testval


def test_upload_link():
    global testval2
    testval2 = str(uuid.uuid4())
    response = client.get(
        f"{base_addr}/upload-link/{bucket}/test2.txt")
    assert response.status_code == 200
    link = response.text.strip('"')
    response = client.put(
        link,
        content=testval2,
        headers={'Content-Type': 'text/plain'})
    assert response.status_code == 200


def test_download_link():
    response = client.get(
        f"{base_addr}/download-link/{bucket}/test2.txt")
    assert response.status_code == 200
    link = response.text.strip('"')
    response = client.get(link)
    assert response.status_code == 200
    assert response.text == testval2


test_app = FastAPI()
test_app.include_router(minio.router)

# API keyauth needs to be configured for the module under test
test_api_key = "valid key"
minio.api_key_auth.valid_key = test_api_key


@pytest.mark.parametrize(
    "route", minio.router.routes, ids=lambda r: r.name
)
def test_missing_api_key(route):
    """
    Endpoints should not be accessible, if no api key is passed.
    """
    assert len(route.methods) == 1, "Test assumes one method per route."
    path = route.path.replace("{bucket_name}", "any-bucket")
    method = next(iter(route.methods))
    test_client = TestClient(test_app)
    response = test_client.request(method=method, url=path)
    assert response.status_code == 403
    assert list(response.json().keys()) == ["detail"], \
        "No data but exception details expected in response body."


@pytest.mark.parametrize(
    "route", minio.router.routes, ids=lambda r: r.name
)
def test_invalid_api_key(route):
    """
    Endpoints should not be accessible, if invalid api key is passed.
    """
    assert len(route.methods) == 1, "Test assumes one method per route."
    path = route.path.replace("{bucket_name}", "any-bucket")
    method = next(iter(route.methods))
    test_client = TestClient(test_app)
    test_client.headers["x-api-key"] = test_api_key[1:]
    response = test_client.request(method=method, url=path)
    assert response.status_code == 401
    assert list(response.json().keys()) == ["detail"], \
        "No data but exception details expected in response body."
