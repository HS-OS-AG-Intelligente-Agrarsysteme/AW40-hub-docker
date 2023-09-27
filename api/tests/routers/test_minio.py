import uuid
from httpx import Client

client = Client()

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
