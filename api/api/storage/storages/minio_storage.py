from minio import Minio
from datetime import timedelta
from ..storage import Storage, StorageData
from typing import BinaryIO
from tempfile import SpooledTemporaryFile


class MinIOStorageData(StorageData):

    def __init__(self, data_handle) -> None:
        self.data = data_handle
        self.content_type = data_handle.headers['Content-Type']
        self.file_buffer = None
        self.file_view_disabled = False

    def get_content_type(self):
        return self.content_type

    def file_view(self):
        if not self.file_view_disabled:
            self.__to_buffer()
            return self.file_buffer
        return None

    def stream_view(self):
        if not self.file_buffer:
            self.file_view_disabled = True
            return self.__iter()
        else:
            self.file_buffer.seek(0)
            return self.__file_iter()

    def __iter(self):
        for chunk in self.data.stream(1024*1024):
            yield chunk

    def __file_iter(self):
        for chunk in self.file_buffer.read(1024*1024):
            yield chunk

    def __to_buffer(self):
        if not self.file_buffer:
            self.file_buffer = SpooledTemporaryFile(1024*1024)
            for chunk in self.__iter():
                self.file_buffer.write(chunk)
            self.file_buffer.seek(0)

    def __del__(self):
        self.data.close()
        self.data.release_conn()


class MinIOStorage(Storage):

    def __init__(self, **kwargs) -> None:
        self.host = kwargs["host"]
        self.username = kwargs["username"]
        self.password = kwargs["password"]
        self.use_tls = kwargs["use_tls"]
        self.check_cert = kwargs["check_cert"]

    def get_data(self, key: str, **attributes) -> StorageData:
        bucket = attributes['bucket']
        client = self.get_minio_client()
        obj_handle = client.get_object(bucket, key)
        return MinIOStorageData(obj_handle)

    def put_data(self, key: str, data: BinaryIO, **attributes):
        bucket = attributes['bucket']
        size = attributes['size']
        content_type = attributes['content_type']

        client = self.get_minio_client()
        client.put_object(bucket,
                          key,
                          data,
                          length=size,
                          content_type=content_type)

    def get_download_link(self, key: str, **attributes):
        client = self.get_minio_client(internal=False)
        bucket = attributes['bucket']
        url = client.presigned_get_object(
            bucket,
            key,
            expires=timedelta(minutes=30)
        )
        return url

    def get_upload_link(self, key: str, **attributes):
        client = self.get_minio_client(internal=False)
        bucket = attributes['bucket']
        url = client.presigned_put_object(
            bucket,
            key,
            expires=timedelta(minutes=30))
        return url

    def get_minio_client(self, internal: bool = True) -> Minio:
        if internal:
            client = Minio(
                endpoint="minio:9000",
                access_key=self.username,
                secret_key=self.password,
                secure=False,
                cert_check=False
            )
        else:
            client = Minio(
                endpoint=self.host,
                access_key=self.username,
                secret_key=self.password,
                secure=self.use_tls,
                cert_check=self.check_cert
            )
        return client
