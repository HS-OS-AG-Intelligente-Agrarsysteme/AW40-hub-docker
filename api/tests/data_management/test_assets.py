import pytest
from api.data_management.assets import AssetDefinition
from pydantic import ValidationError


@pytest.fixture
def vin():
    """
    Real world VIN from
    https://de.wikipedia.org/wiki/Fahrzeug-Identifizierungsnummer
    """
    return "W0L000051T2123456"


class TestAssetDefinition:

    def test_default(self):
        # All attributes are optional
        AssetDefinition()

    @pytest.mark.parametrize("vin_len", [1, 2, *range(10, 18)])
    def test_vin_length_restriction_not_met(self, vin_len, vin):
        with pytest.raises(ValidationError):
            AssetDefinition(vin=vin[:vin_len])

    @pytest.mark.parametrize("vin_len", range(3, 10))
    def test_vin_length_restriction_met(self, vin_len, vin):
        AssetDefinition(vin=vin[:vin_len])

    @pytest.mark.parametrize("dtc", ["P", "P0", "P00", "P000", "P00000"])
    def test_invalid_dtc(self, dtc):
        with pytest.raises(ValidationError):
            AssetDefinition(obd_data_dtc=dtc)

    def test_valid_dtc(self):
        AssetDefinition(obd_data_dtc="P4242")
