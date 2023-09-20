from typing import List

import pytest
from api.data_management.timeseries_data import (
    BaseSignalStore, GridFSSignalStore, NewTimeseriesData, TimeseriesData,
    TimeseriesMetaData
)
from beanie import PydanticObjectId
from pydantic import ValidationError


class TestGridFSSignalStore:

    @pytest.mark.asyncio
    async def test_create_and_get(self, signal_bucket):
        signal_store = GridFSSignalStore(signal_bucket)
        signal = [-1., 0., 1]
        signal_id = await signal_store.create(signal)
        retrieved_signal = await signal_store.get(signal_id)
        assert signal == retrieved_signal

    @pytest.mark.asyncio
    async def test_delete(self, signal_bucket):
        # seed test bucket with empty bytes and keep id
        signal_id = await signal_bucket.upload_from_stream(
            filename="",
            source=b""
        )
        # delete via GridFSSignalStore and confirm non-existence
        signal_store = GridFSSignalStore(signal_bucket)
        await signal_store.delete(signal_id)
        cursor = signal_bucket.find({"_id": signal_id})
        stored_signals = await cursor.to_list(None)
        assert stored_signals == []


class MockSignalStore(BaseSignalStore):
    """
    Mock implementation of the BaseSignalStore interface used for testing
    subclasses of BaseTimeseriesData.
    """

    def __init__(self):
        self.store = {}

    async def create(self, signal: List[float]) -> str:
        new_id = PydanticObjectId()
        self.store[new_id] = signal
        return str(new_id)

    async def get(self, id: str) -> List[float]:
        return self.store[id]

    async def delete(self, id: str):
        self.store.pop(id)


class TestTimeseriesData:

    def test_validation_fails_without_signal_id(self, timeseries_meta_data):
        with pytest.raises(ValidationError):
            TimeseriesData(**timeseries_meta_data)

    def test_validation_succeeds_with_signal_id(self, timeseries_data):
        TimeseriesData(**timeseries_data)

    @pytest.mark.asyncio
    async def test_get_signal(self, timeseries_signal, timeseries_meta_data):
        # init a MockSignalStore and manually add a signal
        signal_store = MockSignalStore()
        signal_id = await signal_store.create(timeseries_signal)

        # configure TimeseriesData class to use the mock store
        TimeseriesMetaData.signal_store = signal_store

        # after adding signal_id to metadata, a TimeseriesData instance can
        # be created
        timeseries_meta_data["signal_id"] = signal_id
        timeseries_data = TimeseriesData(**timeseries_meta_data)

        # retrieve the original signal from the TimeseriesData instance
        retrieved_signal = await timeseries_data.get_signal()
        assert retrieved_signal == timeseries_signal

    @pytest.mark.asyncio
    async def test_delete_signal(
            self, timeseries_signal, timeseries_meta_data
    ):
        # init a MockSignalStore and manually add a signal
        signal_store = MockSignalStore()
        signal_id = await signal_store.create(timeseries_signal)

        # configure TimeseriesData class to use the mock store
        TimeseriesMetaData.signal_store = signal_store

        # after adding signal_id to metadata, a TimeseriesData instance can
        # be created
        timeseries_meta_data["signal_id"] = signal_id
        timeseries_data = TimeseriesData(**timeseries_meta_data)

        # delete the signal from store and confirm non-existence
        await timeseries_data.delete_signal()
        assert signal_store.store == {}


class TestNewTimeseriesData:

    def test_validation_fails_without_signal(self, timeseries_meta_data):
        with pytest.raises(ValidationError):
            NewTimeseriesData(**timeseries_meta_data)

    def test_validation_succeeds_with_signal(self, new_timeseries_data):
        NewTimeseriesData(**new_timeseries_data)

    @pytest.mark.asyncio
    async def test_to_timeseries_data(self, new_timeseries_data):
        # configure class to use MockSignalStore
        signal_store = MockSignalStore()
        TimeseriesMetaData.signal_store = signal_store

        # convert valid data to model instance
        new_timeseries_data = NewTimeseriesData(**new_timeseries_data)

        # function under test should return an instance of TimeseriesData
        timeseries_data = await new_timeseries_data.to_timeseries_data()
        assert isinstance(timeseries_data, TimeseriesData)

        # there should be single id in store that is reference from the newly
        # created TimeseriesData instance
        ids_in_store = list(signal_store.store.keys())
        assert len(ids_in_store) == 1
        assert timeseries_data.signal_id == ids_in_store[0]
