import json
import os
from datetime import datetime, UTC
from enum import Enum
from typing import Optional, Annotated, ClassVar, Literal
from zipfile import ZipFile

from beanie import Document, before_event, Delete
from pydantic import BaseModel, StringConstraints, Field

from .case import Case


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


class PublicationNetwork(str, Enum):
    pontusxdev = "PONTUSXDEV"
    pontusxtest = "PONTUSXTEST"


class PublicationBase(BaseModel):
    network: PublicationNetwork = Field(
        description="Network that an asset is available in via this "
                    "publication",
        default=PublicationNetwork.pontusxdev
    )
    license: str = "CUSTOM"
    price: float = 1.0


class NewPublication(PublicationBase):
    """Schema for new asset publications."""
    nautilus_private_key: str = Field(
        description="Key for dataspace authentication."
    )


class Publication(PublicationBase):
    """Publication information for an asset."""
    did: str = Field(
        description="Id of this publication within its network."
    )
    asset_url: str = Field(
        description="URL to access asset data from the network."
    )
    asset_key: str = Field(
        description="Publication specific key to access data via `asset_url`.",
        exclude=True
    )


class AssetMetaData(BaseModel):
    name: str
    definition: AssetDefinition
    description: str
    timestamp: datetime = Field(default_factory=lambda: datetime.now(UTC))
    type: Literal["dataset"] = "dataset"
    author: str


class Asset(AssetMetaData, Document):
    """DB schema and interface for assets."""

    class Settings:
        name = "assets"

    data_status: AssetDataStatus = AssetDataStatus.defined
    publication: Optional[Publication] = None

    asset_data_dir_path: ClassVar[str] = "asset-data"

    @staticmethod
    def _publication_case_json(case: Case) -> str:
        """Convert a Case into a publication ready json string."""
        # Keep WMI+VDS from VIN and mask VIS. See
        # https://de.wikipedia.org/wiki/Fahrzeug-Identifizierungsnummer#Aufbau
        case.vehicle_vin = case.vehicle_vin[:9] + 8*"*"
        # Exclude fields only relevant for internal data management from case
        exclude = {
            field: True for field in [
                "customer_id", "workshop_id", "diagnosis_id",
                "timeseries_data_added", "obd_data_added", "symptoms_added",
                "status"
            ]
        }
        # Exclude fields only relevant for internal data management from
        # submodels
        for data_submodel in ["timeseries_data", "obd_data", "symptoms"]:
            exclude[data_submodel] = {"__all__": {"data_id"}}

        case_json = case.model_dump_json(exclude=exclude, indent=1)
        return case_json

    @property
    def data_file_name(self):
        """Zip file name of the asset's dataset."""
        return f"{str(self.id)}.zip"

    @property
    def data_file_path(self):
        """Path to this asset's dataset."""
        return os.path.join(
            self.asset_data_dir_path, self.data_file_name
        )

    async def process_definition(self):
        """
        Process the definition of an Asset to prepare the defined data for
        publication in a dataspace.
        """
        self.data_status = AssetDataStatus.processing
        await self.save()
        # Find all cases matching the definition
        cases = await Case.find_in_hub(
            vin=self.definition.vin,
            obd_data_dtc=self.definition.obd_data_dtc,
            timeseries_data_component=self.definition.timeseries_data_component
        )
        # Create a new zip archive for this asset
        with ZipFile(self.data_file_path, "x") as archive:
            archive.mkdir("cases")
            archive.mkdir("signals")
            for case in cases:
                case_id = str(case.id)
                case_json = self._publication_case_json(case)
                archive.writestr(
                    f"cases/{case_id}.json", data=case_json
                )
                for tsd in case.timeseries_data:
                    signal_id = str(tsd.signal_id)
                    signal = await tsd.get_signal()
                    archive.writestr(
                        f"signals/{signal_id}.json", data=json.dumps(signal)
                    )

        self.data_status = AssetDataStatus.ready
        await self.save()

    @before_event(Delete)
    def _delete_asset_data(self):
        """Remove associated data when asset is deleted."""
        # If there is an archive file associated with this asset, delete it.
        if os.path.exists(self.data_file_path):
            os.remove(self.data_file_path)


class NewAsset(BaseModel):
    """Schema for new asset added via the api."""
    name: str
    definition: Optional[AssetDefinition] = AssetDefinition()
    description: str
    author: str
