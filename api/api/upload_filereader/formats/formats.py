from .picoscope_csv import PicoscopeCSVReader
from .picoscope_mat import PicoscopeMATReader
from .vcds_txt import VCDSTXTReader
from .omniview_csv import OmniviewCSVReader

SUPPORTED_FORMATS = {
    "Picoscope CSV": PicoscopeCSVReader,
    "Picoscope MAT": PicoscopeMATReader,
    "VCDS TXT": VCDSTXTReader,
    "Omniview CSV": OmniviewCSVReader
}
