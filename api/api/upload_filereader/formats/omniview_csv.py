import codecs
import csv
import re
from typing import BinaryIO, List

from ..filereader import FileReader, FileReaderException

HEADER_CHECK = re.compile(
    r"^Omniscope-(?P<device_id>[A-Z0-9]+)$")


class OmniviewCSVReader(FileReader):

    def read_file(self, file: BinaryIO) -> List[dict]:
        reader = csv.reader(codecs.iterdecode(file, 'utf-8'), delimiter=",")
        header = next(reader)[0]
        header_check = HEADER_CHECK.match(header)
        if not header_check:
            raise FileReaderException(
                    f"File header does not match Omniview File header but got"
                    f" {header}"
                )
        signal = []
        for i, row in enumerate(reader):
            if len(row) == 0:
                # Ignore empty last row
                break
            elif len(row) != 2:
                raise FileReaderException(
                    f"Expected two entries per row but got {len(row)}."
                )
            elif row[0] != str(i):
                raise FileReaderException(
                    f"Expected first column to match row index but got"
                    f" {row[0]} != {str(i)}."
                )
            else:
                signal.append(float(row[1]))
        return [
            {
                "signal": signal,
                "device_specs": {
                    "type": "omniview",
                    "export_file_header": header
                }
            }
        ]
