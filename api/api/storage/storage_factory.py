from .storage import Storage
from .storages.storages import SUPPORTED_STORAGES


class StorageFactory():
    _config = {}

    def get_storage(self, Name: str) -> Storage:
        cfg = self._config[Name]
        constructor = SUPPORTED_STORAGES[Name]
        return constructor(**cfg)

    @classmethod
    def initialise_storages(cls, **kwargs):
        for name in SUPPORTED_STORAGES.keys():
            prefix = f"{name.lower()}_"
            args = {k.removeprefix(prefix): v for (k, v) in kwargs.items()
                    if k.startswith(prefix)}
            cls._config[name] = args
