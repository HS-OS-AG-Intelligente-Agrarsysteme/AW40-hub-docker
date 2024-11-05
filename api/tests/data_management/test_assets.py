import json
import os
from typing import List
from zipfile import ZipFile

import pytest
from api.data_management import (
    Asset, AssetDefinition, AssetDataStatus, Case, NewOBDData,
    NewTimeseriesData, TimeseriesMetaData, NewSymptom
)
from pydantic import ValidationError

from .test_timeseries_data import MockSignalStore


@pytest.fixture
def vin():
    """
    Real world VIN from
    https://de.wikipedia.org/wiki/Fahrzeug-Identifizierungsnummer
    """
    return "W0L000051T2123456"


@pytest.fixture(autouse=True)
def set_timeseries_data_signal_store_to_mock():
    TimeseriesMetaData.signal_store = MockSignalStore()


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


class TestAsset:

    def _check_archive_case_data(self, case: Case, archive_case_data: dict):
        """
        Validates contents of a single case stored in an archive.
        """
        assert archive_case_data["id"] == str(case.id)
        # Confirm that the vin is correctly masked
        assert (
                archive_case_data["vehicle_vin"] ==
                case.vehicle_vin[:9] + 8 * "*"
        )

        # Confirm that fields only relevant to internal data management
        # are removed from top-level and submodels
        for field in [
            "customer_id", "workshop_id", "diagnosis_id",
            "timeseries_data_added", "obd_data_added", "symptoms_added"
        ]:
            assert field not in archive_case_data
        for submodel in ["timeseries_data", "obd_data", "symptoms"]:
            for submodel_entry in archive_case_data[submodel]:
                assert "data_id" not in submodel_entry

    def _check_archive(self, archive: ZipFile, expected_cases: List[Case]):
        """
        Validates the structure and contents of archives generated with the
        process_definition_method.
        """
        # Get a list of all members (files and directories) in the archive
        archive_members = archive.namelist()

        # Ensure the presence of the presence of the expected "cases/" and
        # "signals/" directories
        assert "cases/" in archive_members
        assert "signals/" in archive_members

        # Track the number of signal files in the archive
        signals_in_archive = 0

        for case in expected_cases:
            # Ensure the expected case path exists in the archive
            archive_case_path = f"cases/{str(case.id)}.json"
            assert archive_case_path in archive_members

            # Load and validate case data stored in the archive
            archive_case_data = json.loads(archive.read(archive_case_path))
            self._check_archive_case_data(case, archive_case_data)

            for tsd in archive_case_data["timeseries_data"]:
                signals_in_archive += 1
                # Ensure the expected signal path exists in the archive
                archive_signal_path = f"signals/{tsd['signal_id']}.json"
                assert archive_signal_path in archive_members
                # Ensure the signal file is valid JSON
                assert json.loads(archive.read(archive_signal_path))

        # Confirm that there is nothing but the expected members (2 directories
        # + cases + signals) in the archive
        assert (
                len(archive_members) == 2 +
                len(expected_cases) +
                signals_in_archive
        )

    @pytest.mark.parametrize(
        "definition,expected_cases_idx",
        [
            (AssetDefinition(), [0, 1, 2]),
            (AssetDefinition(vin="W0L"), [0, 1]),
            (AssetDefinition(vin="W0L1"), [0]),
            (AssetDefinition(obd_data_dtc="P0001"), [0, 2]),
            (AssetDefinition(timeseries_data_component="CompA"), [1, 2]),
            (AssetDefinition(vin="W0L", obd_data_dtc="P0001"), [0]),
            (
                    AssetDefinition(
                        vin="W0L", timeseries_data_component="CompA"
                    ),
                    [1]
            ),
            (
                    AssetDefinition(
                        vin="W0L",
                        timeseries_data_component="CompB",
                        obd_data_dtc="P0001"
                    ),
                    # No case matches the definition. Hence, archive is
                    # expected to be empty.
                    []
            )
        ]
    )
    @pytest.mark.asyncio
    async def test_process_definition(
            self,
            definition,
            expected_cases_idx,
            initialized_beanie_context
    ):
        async with initialized_beanie_context:
            # Three cases with different VINs are stored in the db
            cases = []
            cases.append(
                Case(vehicle_vin="W0L111111T1111111", workshop_id="a")
            )
            cases.append(
                Case(vehicle_vin="W0L222222T2222222", workshop_id="b")
            )
            cases.append(
                Case(vehicle_vin="1111111T150000L0W", workshop_id="c")
            )
            for case in cases:
                await case.create()

            # Add an OBD Dataset to each case
            await cases[0].add_obd_data(NewOBDData(dtcs=["P0001"]))
            await cases[1].add_obd_data(NewOBDData(dtcs=["Q0002"]))
            await cases[2].add_obd_data(NewOBDData(dtcs=["P0001"]))

            # Add timeseries data to subset of cases
            await cases[1].add_timeseries_data(
                NewTimeseriesData(
                    signal=[.0, .1],
                    sampling_rate=1,
                    duration=2,
                    component="CompA",
                    label="unknown"
                )
            )
            await cases[1].add_timeseries_data(
                NewTimeseriesData(
                    signal=[.0, .1, .2],
                    sampling_rate=1,
                    duration=3,
                    component="CompB",
                    label="unknown"
                )
            )
            await cases[2].add_timeseries_data(
                NewTimeseriesData(
                    signal=[.0, .1, .2, .3],
                    sampling_rate=2,
                    duration=2,
                    component="CompA",
                    label="unknown"
                )
            )

            # Add a symptom to one case
            await cases[0].add_symptom(
                NewSymptom(component="CompC", label="defect")
            )

            # Create an asset with the parametrized definition
            asset = await Asset(
                name="Test Asset",
                description="This is an test asset.",
                definition=definition,
                author="test author"
            ).create()

            # Process the definition
            await asset.process_definition()
            # Assert up-to-date data_status in db
            await asset.sync()
            assert asset.data_status == AssetDataStatus.ready

            # Check the zip archive generated for the parametrized definition
            with ZipFile(asset.data_file_path, "r") as archive:
                self._check_archive(
                    archive=archive,
                    expected_cases=[cases[i] for i in expected_cases_idx]
                )

    @pytest.mark.asyncio
    async def test__delete_asset_data(self, initialized_beanie_context):
        """
        Confirm automatic deletion of asset data archive upon asset deletion.
        """
        async with initialized_beanie_context:
            asset = await Asset(
                name="Test Asset",
                description="This is an test asset.",
                definition=AssetDefinition(),
                author="Test author"
            ).create()
            # Test existence of archive file after processing the definition
            await asset.process_definition()
            assert os.path.exists(asset.data_file_path)
            # Test non-existence of archive file after deleting asset from db
            await asset.delete()
            assert not os.path.exists(asset.data_file_path)

    @pytest.mark.asyncio
    async def test__delete_asset_data_without_file(
            self, initialized_beanie_context
    ):
        """
        Confirm that asset deletion passes without an existing archive file.
        """
        async with initialized_beanie_context:
            asset = await Asset(
                name="Test Asset",
                description="This is an test asset.",
                definition=AssetDefinition(),
                author="Test author"
            ).create()
            # Delete before an archive file was created
            await asset.delete()
