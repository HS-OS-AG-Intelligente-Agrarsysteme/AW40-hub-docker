from datetime import datetime
from typing import List

from pydantic import BaseModel, Field, constr, NonNegativeInt


class OBDMetaData(BaseModel):
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    obd_specs: dict = None


class NewOBDData(OBDMetaData):
    """Schema for new obd data added via the api."""

    class Config:
        json_schema_extra = {
            "example": {
                "dtcs": ["P0001", "U0001"]
            }
        }

    dtcs: List[constr(min_length=5, max_length=5)]


class OBDData(NewOBDData):
    """Schema for existing timeseries data."""

    class Config:
        json_schema_extra = {
            "example": {
                "timestamp": "2023-04-04T07:11:24.032000",
                "obd_specs": None,
                "dtcs": ["P0001", "U0001"],
                "data_id": 0
            }
        }

    data_id: NonNegativeInt = None


class OBDDataUpdate(BaseModel):
    """Schema for updating obd meta data."""

    class Config:
        json_schema_extra = {
            "example": {
                "obd_specs": {"device": "VCDS"},
            }
        }

    timestamp: datetime = None
    obd_specs: dict = None
