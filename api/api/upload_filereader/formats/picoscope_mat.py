from scipy.io import loadmat
from typing import BinaryIO, List

from ..filereader import FileReader, FileReaderException


class PicoscopeMATReader(FileReader):
    def read_file(self, file):
        measurement = self.__read_mat(file)
        return measurement

    def __read_mat(self, file: BinaryIO) -> List[dict]:
        try:
            f = loadmat(file)
        except Exception:
            raise FileReaderException("conversion error: failed to load file")
        result = []
        if 'Tinterval' not in f.keys():
            raise FileReaderException("conversion error: missing Tinterval")
        if 'Length' not in f.keys():
            raise FileReaderException("conversion error: missing Length")
        channels = [x for x in f.keys() if len(x) == 1]
        sampling_rate: int = round(1.0/f['Tinterval'].item(0))
        duration: int = round(f['Tinterval'].item(0) * f['Length'].item(0))
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
