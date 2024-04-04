import pytest
from api.upload_filereader.filereader import FileReaderException
from api.upload_filereader.formats.omniview_csv import OmniviewCSVReader


class TestOmniviewCSVReader:

    def test_read_file(
            self, omniview_csv_file
    ):
        # convert file
        reader = OmniviewCSVReader()
        result = reader.read_file(omniview_csv_file)

        # assert expectations
        assert isinstance(result, list)
        assert len(result) == 1
        result = result[0]
        assert len(result["signal"]) == 100
        assert result["signal"][:2] == [46, 47]
        assert result["signal"][-2:] == [46, 47]
        assert result["device_specs"]["type"] == "omniscope"
        assert result["device_specs"]["device_id"] == \
               "E46920935F320D2D"

    def test_read_sin_file(
            self, omniview_sin_csv_file
    ):
        # convert file
        reader = OmniviewCSVReader()
        result = reader.read_file(omniview_sin_csv_file)

        # assert expectations
        assert isinstance(result, list)
        assert len(result) == 1
        result = result[0]
        assert len(result["signal"]) == 705
        assert result["signal"][:2] == [115, 115]
        assert result["signal"][-4:] == [2, 0, -2, -3]
        assert result["device_specs"]["type"] == "omniscope"
        assert result["device_specs"]["device_id"] == \
               "E46228B163272D25"

    @pytest.mark.parametrize(
        "file",
        [
            "picoscope_1ch_eng_csv_file", "picoscope_4ch_eng_csv_file"
        ]
    )
    def test_read_file_wrong_format(self, file, request):
        file = request.getfixturevalue(file)
        with pytest.raises(FileReaderException):
            OmniviewCSVReader().read_file(file)
