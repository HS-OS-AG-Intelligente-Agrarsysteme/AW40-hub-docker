from .filereader import FileReader
from .formats import formats


class FilereaderFactory:
    def get_reader(self, format: str) -> FileReader:
        reader_cls = formats.SUPPORTED_FORMATS[format]
        return reader_cls()


filereader_factory = FilereaderFactory()
