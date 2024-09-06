from fastapi import APIRouter, HTTPException, Request, Header, Depends
from fastapi.responses import StreamingResponse
from tempfile import SpooledTemporaryFile
import logging
from ..storage.storage_factory import StorageFactory
from ..security.api_key_auth import APIKeyAuth

tags_metadata = [
    {
        "name": "MinIO - MinIO interface",
        "description": "Get/Put data to/from MinIO."
    }
]

api_key_auth = APIKeyAuth()

router = APIRouter(tags=["MinIO"], dependencies=[Depends(api_key_auth)])


@router.get(
    "/download-link/{bucket_name}/{key_name}"
)
async def get_file_download_link(
    bucket_name: str,
    key_name: str
) -> str:
    storage = StorageFactory().get_storage("MinIO")
    try:
        url = storage.get_download_link(key=key_name,
                                        bucket=bucket_name)
    except Exception as e:
        logging.warning(e)
        raise HTTPException(status_code=403, detail="Item not found")
    return url


@router.get(
    "/upload-link/{bucket_name}/{key_name}"
)
async def get_file_upload_link(
    bucket_name: str,
    key_name: str
) -> str:
    storage = StorageFactory().get_storage("MinIO")
    try:
        url = storage.get_upload_link(key=key_name,
                                      bucket=bucket_name)
    except Exception as e:
        logging.warning(e)
        raise HTTPException(status_code=403, detail="Item not found")
    return url


@router.get(
    "/{bucket_name}/{key_name}"
)
async def get_file(
    bucket_name: str,
    key_name: str
) -> StreamingResponse:
    storage = StorageFactory().get_storage("MinIO")
    try:
        data = storage.get_data(key=key_name,
                                bucket=bucket_name)
        headers = {
            "Content-Disposition": f"inline; filename=\"{key_name}\""
        }
        return StreamingResponse(data.stream_view(),
                                 media_type=data.get_content_type(),
                                 headers=headers)
    except Exception as e:
        logging.warning(e)
        raise HTTPException(status_code=403, detail="Item not found")


@router.put(
    "/{bucket_name}/{key_name}",
    status_code=200
)
async def upload_file(
    bucket_name: str,
    key_name: str,
    request: Request,
    content_type: str = Header(default='application/octet-stream')
) -> str:
    storage = StorageFactory().get_storage("MinIO")
    try:
        file = SpooledTemporaryFile(1024*1024)
        size = 0
        async for chunk in request.stream():
            size = size + len(chunk)
            file.write(chunk)
        file.seek(0)
        storage.put_data(key=key_name,
                         bucket=bucket_name,
                         content_type=content_type,
                         data=file,  # type: ignore
                         size=size)
        return key_name
    except Exception as e:
        logging.warning(e)
        raise HTTPException(status_code=403, detail="Item not found")
