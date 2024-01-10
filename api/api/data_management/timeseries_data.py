from abc import ABC
from datetime import datetime
from enum import Enum
from typing import List, ClassVar, Literal

import numpy as np
from beanie import PydanticObjectId
from motor import motor_asyncio
from pydantic import BaseModel, Field, NonNegativeInt


class BaseSignalStore(ABC):
    """Interface definition for a signal store."""

    async def create(self, signal: List[float]) -> str:
        """Store the signal and return the storage id."""
        raise NotImplementedError

    async def get(self, id: str) -> List[float]:
        """Get a signal by storage id."""
        raise NotImplementedError

    async def delete(self, id: str):
        """Delete a signal by storage id."""
        raise NotImplementedError


class GridFSSignalStore(BaseSignalStore):
    """MongoDB GridFS based signal store."""

    def __init__(self, bucket: motor_asyncio.AsyncIOMotorGridFSBucket):
        self._bucket = bucket

    async def create(self, signal: List[float]) -> str:
        signal_bytes = np.array(signal).tobytes()
        id = await self._bucket.upload_from_stream(
            filename="",
            source=signal_bytes
        )
        return id

    async def get(self, id: str) -> List[float]:
        grid_out = await self._bucket.open_download_stream(id)
        signal_bytes = await grid_out.read()
        signal = np.frombuffer(signal_bytes, dtype=float).tolist()
        return signal

    async def delete(self, id: str):
        await self._bucket.delete(id)


class TimeseriesDataLabel(str, Enum):
    unknown = "unknown"
    norm = "norm"
    anomaly = "anomaly"


class TimeseriesMetaData(BaseModel):
    """Schema for timeseries meta data."""

    class Config:
        validate_assignment = True

    timestamp: datetime = Field(default_factory=datetime.utcnow)
    component: str
    label: TimeseriesDataLabel
    sampling_rate: int
    duration: int
    type: Literal["oscillogram"] = "oscillogram"
    device_specs: dict = None

    # signal_store to convert between actual signal data and signal data
    # references in subclasses
    signal_store: ClassVar[BaseSignalStore]


class TimeseriesDataUpdate(BaseModel):
    """Schema for updating timeseries meta data."""

    class Config:
        schema_extra = {
            "example": {
                "label": "anomaly",
            }
        }

    timestamp: datetime = None
    component: str = None
    label: TimeseriesDataLabel = None
    sampling_rate: int = None
    duration: int = None
    type: str = None
    device_specs: dict = None


class TimeseriesData(TimeseriesMetaData):
    """Schema for existing timeseries data."""

    class Config:
        json_encoders = {
            PydanticObjectId: str,
        }
        schema_extra = {
            "example": {
                "timestamp": "2023-04-04T07:07:22.643103",
                "component": "battery",
                "label": "norm",
                "sampling_rate": 1,
                "duration": 3,
                "type": "oscillogram",
                "device_specs": None,
                "data_id": 0,
                "signal_id": "642bccaa392b553201b2ac9f"
            }
        }

    data_id: NonNegativeInt = None

    # Ref to signal data instead of actual data
    signal_id: PydanticObjectId

    async def get_signal(self):
        """Fetches the actual signal data on demand."""
        return await self.signal_store.get(self.signal_id)

    async def delete_signal(self):
        """Delete the actual signal data."""
        await self.signal_store.delete(self.signal_id)


class NewTimeseriesData(TimeseriesMetaData):
    """Schema for new timeseries data added via the api."""

    class Config:
        schema_extra = {
            "example": {
                "component": "battery",
                "label": "norm",
                "sampling_rate": 1,
                "duration": 3,
                "type": "oscillogram",
                "signal": [0., 1., 2.]
            }
        }

    signal: List[float]

    async def to_timeseries_data(self) -> TimeseriesData:
        """
        Store the signal using configured signal store and create a
        TimeseriesData instance that holds a reference to the stored signal
        data.
        """
        signal_id = await self.signal_store.create(self.signal)
        meta_data = self.dict(exclude={"signal"})
        meta_data["signal_id"] = signal_id
        return TimeseriesData(**meta_data)


class TimeseriesDataFull(TimeseriesData):
    signal: List[float]
