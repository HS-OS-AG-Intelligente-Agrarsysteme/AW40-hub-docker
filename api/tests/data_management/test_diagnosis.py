import pytest

from api.data_management import (
    Case,
    Diagnosis,
    DiagnosisStatus
)


class TestDiagnosis:

    @pytest.mark.asyncio
    async def test_find_in_hub_without_data(self, initialized_beanie_context):
        async with initialized_beanie_context:
            diagnoses = await Diagnosis.find_in_hub(workshop_id="any")
            assert diagnoses == [], "Expected empty list."

    @pytest.mark.asyncio
    async def test_find_in_hub(self, initialized_beanie_context):
        async with initialized_beanie_context:
            # Seed db with 2 cases for workshop "1"
            case_11 = await Case(workshop_id="1", vehicle_vin="v11").insert()
            case_12 = await Case(workshop_id="1", vehicle_vin="v12").insert()
            # Seed db with 1 case for workshop "2"
            case_21 = await Case(workshop_id="2", vehicle_vin="v21").insert()  # noqa F841

            # Both cases of workshop "1" have a diagnosis
            assert case_11.id
            diag_11 = await Diagnosis(  # noqa F841
                case_id=case_11.id, status=DiagnosisStatus("scheduled")
            ).insert()
            assert case_12.id
            diag_12 = await Diagnosis(
                case_id=case_12.id, status=DiagnosisStatus("finished")
            ).insert()

            workshop_1_result = await Diagnosis.find_in_hub(workshop_id="1")
            assert len(workshop_1_result) == 2, \
                "Expected 2 diagnoses for workshop 1."

            workshop_1_finished_result = await Diagnosis.find_in_hub(
                workshop_id="1", status=DiagnosisStatus("finished")
            )
            assert len(workshop_1_finished_result) == 1
            assert workshop_1_finished_result[0].id == diag_12.id, \
                "Expected 1 diagnosis with status finished for workshop 1."

            workshop_2_result = await Diagnosis.find_in_hub(workshop_id="2")
            assert workshop_2_result == [], \
                "Expected 0 diagnoses for workshop 2."
