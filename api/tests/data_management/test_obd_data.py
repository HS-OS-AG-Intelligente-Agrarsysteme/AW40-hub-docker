import pytest
from api.data_management import OBDData
from pydantic import ValidationError


class TestOBDData:

    def test_valid_dtcs(self):
        OBDData(dtcs=["P0001"])

    @pytest.mark.parametrize(
        "invalid_dtcs",
        [1, "P0001", ["P000", "P0001"], ["P00001", "P0001"]]
    )
    def test_invalid_dtcs(self, invalid_dtcs):
        with pytest.raises(ValidationError):
            OBDData(dtcs=invalid_dtcs)
