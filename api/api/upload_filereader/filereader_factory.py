from .formats import formats
from .filereader import FileReader


class FilereaderFactory:
    def get_reader(self, format: str) -> FileReader:
        reader_cls = formats.SUPPORTED_FORMATS[format]
        return reader_cls()


filereader_factory = FilereaderFactory()
