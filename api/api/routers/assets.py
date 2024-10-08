import secrets
from typing import List

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, Request
from fastapi.responses import FileResponse
from fastapi.security import APIKeyHeader

from ..data_management import NewAsset, Asset, Publication, AssetDataStatus
from ..dataspace_management import Nautilus
from ..security.token_auth import authorized_assets_access

tags_metadata = [
    {
        "name": "Dataspace Assets",
        "description": "Proprietary dataspace asset management."
    },
    {
        "name": "Public Dataspace Resources",
        "description": "Access to resources shared within the dataspace."
    }
]

management_router = APIRouter(
    tags=["Dataspace Assets"],
    prefix="/dataspace/manage",
    dependencies=[Depends(authorized_assets_access)]
)

public_router = APIRouter(
    tags=["Public Dataspace Resources"],
    prefix="/dataspace/public"
)


@management_router.get("/assets", status_code=200, response_model=List[Asset])
async def list_assets(
):
    """Retrieve list of assets."""
    return await Asset.find().to_list()


@management_router.post("/assets", status_code=201, response_model=Asset)
async def add_asset(
        asset: NewAsset, background_tasks: BackgroundTasks
):
    """
    Add a new asset.

    Afterwards, data will be processed and packaged for publication in the
    background.
    """
    _asset = await Asset(**asset.model_dump()).create()
    background_tasks.add_task(_asset.process_definition)
    return _asset


async def asset_by_id(asset_id: str) -> Asset:
    """
    Reusable dependency to handle retrieval of assets by ID. 404 HTTP
    exception is raised in case of invalid id.
    """
    # Invalid ID format causes 404
    try:
        asset_oid = ObjectId(asset_id)
    except InvalidId:
        raise HTTPException(
            status_code=404, detail="Invalid format for asset_id."
        )
    # Non-existing ID causes 404
    asset = await Asset.get(asset_oid)
    if asset is None:
        raise HTTPException(
            status_code=404,
            detail=f"No asset with id '{asset_id}' found."
        )

    return asset


@management_router.get(
    "/assets/{asset_id}", status_code=200, response_model=Asset
)
async def get_asset(
        asset: Asset = Depends(asset_by_id)
):
    """Get an Asset by ID."""
    return asset


@management_router.delete(
    "/assets/{asset_id}", status_code=200, response_model=None
)
async def delete_asset(
        asset: Asset = Depends(asset_by_id)
):
    """Delete an Asset."""
    await asset.delete()
    return None


@management_router.get(
    "/assets/{asset_id}/data", status_code=200, response_class=FileResponse
)
async def get_asset_dataset(
        asset: Asset = Depends(asset_by_id),
):
    """Download the dataset of an Asset."""
    if asset.data_status != AssetDataStatus.ready:
        raise HTTPException(
            status_code=400,
            detail="Preparation of asset data hasn't finished, yet."
        )
    return FileResponse(
        path=asset.data_file_path, filename=asset.data_file_name
    )


@management_router.post(
    "/assets/{asset_id}/publication",
    status_code=201,
    response_model=Publication
)
async def publish_asset(
        request: Request,
        asset: Asset = Depends(asset_by_id),
        nautilus: Nautilus = Depends(Nautilus)
):
    """Publish the asset in the dataspace."""
    if asset.data_status != AssetDataStatus.ready:
        raise HTTPException(
            status_code=400,
            detail=f"Asset cannot be published until data_status is "
                   f"{AssetDataStatus.ready.value}."
        )
    # If asset is already published, respond with publication information and
    # 200 instead of 201 to indicate that no new resource was created.
    if asset.publication is not None:
        return asset.publication, 200

    # New publication
    # The full URL for data access depends on deployment and mounting prefixes.
    # Hence, split requested URL by management router prefix, keep the first
    # part and append the url path of the get_published_dataset endpoint to
    # make sure that the asset_url points to  the appropriate  location for the
    # current environment.
    asset_url = "".join(
        [
            str(request.url).split(management_router.prefix)[0],
            public_router.url_path_for(
                "get_published_dataset", asset_id=asset.id
            )
        ]
    )
    # Use nautilus to trigger the publication and store publication info
    # within the asset.
    publication = nautilus.publish_access_dataset(
        asset_url=asset_url, asset=asset
    )
    asset.publication = publication
    await asset.save()
    return publication


@public_router.get(
    "/assets/{asset_id}/data",
    status_code=200,
    response_class=FileResponse
)
async def get_published_dataset(
        asset: Asset = Depends(asset_by_id),
        asset_key: str = Depends(APIKeyHeader(name="asset_key"))
):
    """Public download link for asset data."""
    publication = asset.publication
    if publication is None:
        raise HTTPException(
            status_code=404,
            detail=f"No published asset with ID '{asset.id}' found."
        )
    asset_key_valid = secrets.compare_digest(publication.asset_key, asset_key)
    if not asset_key_valid:
        raise HTTPException(
            status_code=401,
            detail="Could not validate asset key.",
            headers={"WWW-Authenticate": "asset_key"},
        )
    return FileResponse(
        path=asset.data_file_path, filename=asset.data_file_name
    )
