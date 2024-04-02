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
        assert result["device_specs"]["type"] == "omniview"
        assert result["device_specs"]["export_file_header"] == \
               "Omniscope-E46920935F320D2D"

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
