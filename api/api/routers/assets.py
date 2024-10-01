from typing import List

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException

from ..data_management import NewAsset, Asset

tags_metadata = [
    {
        "name": "Assets",
        "description": "Dataspace asset management"
    }
]

router = APIRouter(
    tags=["Dataspace Assets"],
    dependencies=[]  # TODO: Access control
)


@router.get("/", status_code=200, response_model=List[Asset])
async def list_assets(
):
    """Retrieve list of assets."""
    return await Asset.find().to_list()


@router.post("/", status_code=201, response_model=Asset)
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


@router.get("/{asset_id}", status_code=200, response_model=Asset)
async def get_asset(
        asset: Asset = Depends(asset_by_id)
):
    """Get an Asset by ID."""
    return asset


@router.delete("/{asset_id}", status_code=200, response_model=None)
async def delete_asset(
    asset: Asset = Depends(asset_by_id)
):
    """Delete an Asset."""
    await asset.delete()
    return None
