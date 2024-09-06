import codecs
import csv
import re
from typing import BinaryIO, List, Tuple, Dict

from ..filereader import FileReader, FileReaderException

conv_table = {
    "(s)": 1e0,
    "(ms)": 1e-3,
    "(μs)": 1e-6,
    "(V)": 1e0,
    "(mV)": 1e-3,
    "(μV)": 1e-6
}

time_names = [
    "Zeit",
    "Time"
]

HEADER_CHECK = re.compile(
    r"^.+(?P<delimiter>[,;])(?:.+ [A-Z])(?:\1.+ [A-Z])*$")
CONVHEADER_CHECK = re.compile(
    r"^\((?:m|μ){0,1}(?:s|V)\)(?:[,;]\((?:m|μ){0,1}(?:s|V)\))+$")
CHANNEL_CHECK = re.compile(
    r"^(?P<channel_name>.+) (?P<channel>[A-Z])$")


class PicoscopeCSVReader(FileReader):
    def read_file(self, file: BinaryIO) -> List[dict]:
        result = []
        validated, delimiter = self.__probe(file)
        if not validated:
            raise FileReaderException("conversion failed: wrong format")
        data: Dict = self.__csv_to_dict(file, delimiter)
        duration: int = round(self.__calculate_duration(data))
        sampling_rate: int = round(self.__calculate_sampling_rate(data)[0])
        for key in data.keys():
            if key.startswith('Channel'):
                result.append({
                    'duration': duration,
                    'sampling_rate': sampling_rate,
                    'signal': data[key],
                    'device_specs': {
                        "channel": key.replace('Channel ', ''),
                        "type": "picoscope"
                    }
                })
        return result

    def __translate_header(self, header) -> List[str]:
        translated = []
        for item in header:
            if item in time_names:
                translated.append("Time")
            else:
                channel_check = CHANNEL_CHECK.match(item)
                if channel_check:
                    channel = channel_check["channel"]
                    translated.append("Channel {}".format(channel))
        if len(translated) != len(header):
            raise FileReaderException(
                "conversion failed: failed to translate header"
            )
        return translated

    def __probe(self, file) -> Tuple[bool, str]:
        try:
            file_iter = codecs.iterdecode(file, "utf-8")
            header = next(file_iter).strip()
            conv_header = next(file_iter).strip()
        except Exception:
            raise FileReaderException(
                "conversion failed: failed to read two lines"
            )
        header_check = HEADER_CHECK.match(header)
        conv_header_check = CONVHEADER_CHECK.match(conv_header)
        file.seek(0)
        if header_check and conv_header_check:
            return True, header_check["delimiter"]
        return False, ""

    def __csv_to_dict(self, file, delimiter) -> Dict:
        reader = csv.reader(codecs.iterdecode(file, 'utf-8'),
                            delimiter=delimiter)
        header = self.__translate_header(next(reader))
        data = {}
        conversion = []

        for column in header:
            data[column] = []

        for type in next(reader):
            conversion.append(conv_table[type])

        for row in reader:
            if len(row) > 0 and len(row) != len(header):
                raise FileReaderException(
                    "conversion failed: discontinuity detected"
                )
            for count, element in enumerate(row):
                try:
                    data[header[count]].append(
                        self.__cast_to_float(element) * conversion[count])
                except Exception as e:
                    raise FileReaderException(
                        "conversion failed:{}".format(str(e))
                    )
        return data

    def __calculate_duration(self, data: dict) -> float:
        return abs(data['Time'][0]) + data['Time'][-1]

    def __cast_to_float(self, value: str) -> float:
        return float(value.replace(",", "."))

    def __calculate_sampling_rate(
        self, data: dict
    ) -> Tuple[float, float, float]:
        sr_arr: List[float] = []
        last: float = 0
        for cnt, ent in enumerate(data['Time']):
            if cnt > 0:
                # Check aroung Time 0 since Picoscope start with negative time
                if last < 0 and ent >= 0:
                    sr_arr.append(1.0 / (abs(abs(last) + abs(ent))))
                else:
                    sr_arr.append(1.0 / (abs(abs(last) - abs(ent))))
            last = ent
        sr: float = (sum(sr_arr) / len(sr_arr))

        return sr, min(sr_arr) - sr, max(sr_arr) - sr
