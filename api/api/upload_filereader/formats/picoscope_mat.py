from scipy.io import loadmat
from typing import BinaryIO, List, Dict

from ..filereader import FileReader, FileReaderException


class PicoscopeMATReader(FileReader):
    def read_file(self, file) -> List[Dict]:
        measurement = self.__read_mat(file)
        return measurement

    def __read_mat(self, file: BinaryIO) -> List[Dict]:
        try:
            f: dict = loadmat(file)
        except Exception:
            raise FileReaderException("conversion error: failed to load file")
        result = []
        if 'Tinterval' not in f.keys():
            raise FileReaderException("conversion error: missing Tinterval")
        if 'Length' not in f.keys():
            raise FileReaderException("conversion error: missing Length")
        sampling_rate: int = round(1.0/f['Tinterval'].item(0))
        duration: int = round(f['Tinterval'].item(0) * f['Length'].item(0))
        channels: List[str] = [x for x in f.keys() if len(x) == 1]
        if len(channels) == 0:
            raise FileReaderException("conversion error: no channels found")
        for channel in channels:
            result.append({
                'sampling_rate': sampling_rate,
                'duration': duration,
                'signal': f[channel].ravel().tolist(),
                'device_specs': {
                    "channel": channel,
                    "type": "picoscope"
                }
            })
        return result
