from numbers import Number

import numpy as np
import pytest
from api.upload_filereader.filereader import FileReaderException
from api.upload_filereader.formats.picoscope_csv import PicoscopeCSVReader


class TestPicoscopeCSVReader:

    @pytest.mark.parametrize(
        "file,expected_channels,expected_first_row",
        [
            (
                "picoscope_1ch_eng_csv_file", ["A"], [0.76307210]
            ),
            (
                "picoscope_4ch_eng_csv_file",
                ["A", "B", "C", "D"],
                [0.76307210, -0.76977730, -0.73618970, -0.62472320]
            ),
            (
                "picoscope_1ch_ger_csv_file", ["A"], [0.76307210]
            ),
            (
                "picoscope_4ch_ger_csv_file",
                ["A", "B", "C", "D"],
                [0.76307210, -0.76977730, -0.73618970, -0.62472320]
            ),
            (
                "picoscope_8ch_ger_comma_decimal_csv_file",
                ["A", "B", "C", "D", "E", "F", "G", "H"],
                [
                    0.75753870, 2.25064100, 5.68459300, 5.01922800, 0.74807720,
                    1.22756700, 0.75448660, 1.00995000
                ]
            )
        ]
    )
    def test_read_file(
            self, file, expected_channels, expected_first_row, request
    ):
        # use request fixture to convert file parameter from str to actual
        # value of picoscope file fixture
        file = request.getfixturevalue(file)

        # convert file
        reader = PicoscopeCSVReader()
        result = reader.read_file(file)

        # assert expectations
        assert isinstance(result, list)
        assert len(result) == len(expected_channels)
        for i, data in enumerate(result):
            assert isinstance(data["sampling_rate"], Number)
            assert isinstance(data["duration"], Number)
            assert isinstance(data["signal"], list)
            assert data["device_specs"]["channel"] == expected_channels[i]
            assert data["device_specs"]["type"] == "picoscope"
            assert np.isclose(data["signal"][0], expected_first_row[i])

    @pytest.mark.parametrize(
        "file",
        [
            "vcds_txt_file", "picoscope_1ch_mat_file"
        ]
    )
    def test_read_file_wrong_format(self, file, request):
        file = request.getfixturevalue(file)
        with pytest.raises(FileReaderException):
            PicoscopeCSVReader().read_file(file)
