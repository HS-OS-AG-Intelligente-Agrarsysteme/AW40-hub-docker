from datetime import datetime, UTC
from typing import List, Optional, Annotated

from pydantic import (
    BaseModel,
    Field,
    NonNegativeInt,
    ConfigDict,
    StringConstraints
)


class OBDMetaData(BaseModel):
    timestamp: datetime = Field(default_factory=lambda: datetime.now(UTC))
    obd_specs: Optional[dict] = None


class NewOBDData(OBDMetaData):
    """Schema for new obd data added via the api."""

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "dtcs": ["P0001", "U0001"]
            }
        }
    )

    dtcs: List[Annotated[str, StringConstraints(min_length=5, max_length=5)]]


class OBDData(NewOBDData):
    """Schema for existing timeseries data."""

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "timestamp": "2023-04-04T07:11:24.032000",
                "obd_specs": None,
                "dtcs": ["P0001", "U0001"],
                "data_id": 0
            }
        }
    )

    data_id: Optional[NonNegativeInt] = None


class OBDDataUpdate(BaseModel):
    """Schema for updating obd meta data."""

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "obd_specs": {"device": "VCDS"},
            }
        }
    )

    timestamp: Optional[datetime] = None
    obd_specs: Optional[dict] = None
