from abc import ABC
from datetime import datetime, UTC
from enum import Enum
from typing import List, ClassVar, Literal, Optional, Any

import numpy as np
from beanie import PydanticObjectId
from motor import motor_asyncio
from pydantic import (
    BaseModel,
    Field,
    NonNegativeInt,
    ConfigDict
)


class BaseSignalStore(ABC):
    """Interface definition for a signal store."""

    async def create(self, signal: List[float]) -> Any:
        """Store the signal and return the storage id."""
        del signal
        raise NotImplementedError

    async def get(self, id: Any) -> List[float]:
        """Get a signal by storage id."""
        del id
        raise NotImplementedError

    async def delete(self, id: Any):
        """Delete a signal by storage id."""
        del id
        raise NotImplementedError


class GridFSSignalStore(BaseSignalStore):
    """MongoDB GridFS based signal store."""

    def __init__(self, bucket: motor_asyncio.AsyncIOMotorGridFSBucket):
        self._bucket = bucket

    async def create(self, signal: List[float]) -> Any:
        signal_bytes = np.array(signal).tobytes()
        id = await self._bucket.upload_from_stream(
            filename="",
            source=signal_bytes
        )
        return id

    async def get(self, id: Any) -> List[float]:
        grid_out = await self._bucket.open_download_stream(id)
        signal_bytes = await grid_out.read()
        signal = np.frombuffer(signal_bytes, dtype=float).tolist()
        return signal

    async def delete(self, id: Any):
        await self._bucket.delete(id)


class TimeseriesDataLabel(str, Enum):
    unknown = "unknown"
    norm = "norm"
    anomaly = "anomaly"


class TimeseriesMetaData(BaseModel):
    """Schema for timeseries meta data."""

    model_config = ConfigDict(
        validate_assignment=True
    )

    timestamp: datetime = Field(default_factory=lambda: datetime.now(UTC))
    component: str
    label: TimeseriesDataLabel
    sampling_rate: int
    duration: int
    type: Literal["oscillogram"] = "oscillogram"
    device_specs: Optional[dict] = None

    # signal_store to convert between actual signal data and signal data
    # references in subclasses
    signal_store: ClassVar[BaseSignalStore]


class TimeseriesDataUpdate(BaseModel):
    """Schema for updating timeseries meta data."""

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "label": "anomaly",
            }
        }
    )

    timestamp: Optional[datetime] = None
    component: Optional[str] = None
    label: Optional[TimeseriesDataLabel] = None
    sampling_rate: Optional[int] = None
    duration: Optional[int] = None
    type: Optional[str] = None
    device_specs: Optional[dict] = None


class TimeseriesData(TimeseriesMetaData):
    """Schema for existing timeseries data."""

    model_config = ConfigDict(
        json_encoders={
            PydanticObjectId: str,
        },
        json_schema_extra={
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
    )

    data_id: Optional[NonNegativeInt] = None

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

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "component": "battery",
                "label": "norm",
                "sampling_rate": 1,
                "duration": 3,
                "type": "oscillogram",
                "signal": [0., 1., 2.]
            }
        }
    )

    signal: List[float]

    async def to_timeseries_data(self) -> TimeseriesData:
        """
        Store the signal using configured signal store and create a
        TimeseriesData instance that holds a reference to the stored signal
        data.
        """
        signal_id = await self.signal_store.create(self.signal)
        meta_data = self.model_dump(exclude={"signal"})
        meta_data["signal_id"] = signal_id
        return TimeseriesData(**meta_data)


class TimeseriesDataFull(TimeseriesData):
    signal: List[float]
