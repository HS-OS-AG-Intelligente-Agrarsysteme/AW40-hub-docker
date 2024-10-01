from datetime import datetime, UTC
from enum import Enum
from typing import Optional, Annotated

from beanie import Document
from pydantic import BaseModel, StringConstraints, Field


class AssetDataStatus(str, Enum):
    defined = "defined"
    processing = "processing"
    ready = "ready"


class AssetDefinition(BaseModel):
    """
    Defines filter conditions that cases have to match to be included in an
    asset.
    """
    vin: Optional[
        Annotated[str, StringConstraints(min_length=3, max_length=9)]
    ] = Field(
        default=None,
        description="Partial VIN used to filter cases for inclusion in the "
                    "asset."
    )
    obd_data_dtc: Optional[
        Annotated[str, StringConstraints(min_length=5, max_length=5)]
    ] = Field(
        default=None,
        description="DTC that has to be present in a case's OBD datasets for "
                    "inclusion in the asset."
    )
    timeseries_data_component: Optional[str] = Field(
        default=None,
        description="Timeseries data component that has to be present in a "
                    "case's timeseries datasets for inclusion in the asset."
    )


class Asset(Document):
    """DB schema and interface for assets."""

    class Settings:
        name = "assets"

    definition: AssetDefinition
    description: Optional[str]
    timestamp: datetime = Field(default_factory=lambda: datetime.now(UTC))
    data_status: AssetDataStatus = AssetDataStatus.defined

    async def process_definition(self):
        """
        Process the definition of an Asset to prepare the defined data for
        publication in a dataspace.
        """
        self.data_status = AssetDataStatus.processing
        await self.save()
        # TODO: Collect data, anonymize and package
        self.data_status = AssetDataStatus.ready
        await self.save()


class NewAsset(BaseModel):
    """Schema for new asset added via the api."""
    definition: Optional[AssetDefinition] = AssetDefinition()
    description: Optional[str] = None
