from abc import ABC
from typing import BinaryIO


class StorageData(ABC):
    def stream_view(self):
        raise NotImplementedError

    def file_view(self):
        raise NotImplementedError

    def string_view(self):
        raise NotImplementedError

    def get_content_type(self) -> str:
        raise NotImplementedError


class Storage(ABC):
    def __init__(self, **kwargs) -> None:
        pass

    def get_data(self, key: str, **attributes):
        raise NotImplementedError

    def get_data_stream(self, key: str, **attributes):
        raise NotImplementedError

    def put_data(self, key: str, **attributes):
        raise NotImplementedError

    def get_download_link(self, key: str, data: BinaryIO, **attributes):
        raise NotImplementedError

    def get_upload_link(self, key: str, **attributes):
        raise NotImplementedError


class StorageException(ValueError):
    pass
