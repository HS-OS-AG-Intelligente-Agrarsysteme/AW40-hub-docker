from unittest import mock

import pytest
from api.data_management import (
    NewCase,
    Case,
    Vehicle,
    TimeseriesDataUpdate,
    NewTimeseriesData,
    TimeseriesData,
    TimeseriesDataLabel,
    NewOBDData,
    OBDDataUpdate,
    NewSymptom,
    SymptomUpdate,
    SymptomLabel
)
from bson import ObjectId
from pydantic import ValidationError


@pytest.fixture
def new_case():
    """Valid meta data for a new case"""
    return {
        "vehicle_vin": "test-vin",
        "occasion": "unknown",
        "milage": 42
    }


@pytest.fixture
def case_with_diagnostic_data(new_case, timeseries_data):
    """Valid data for a case"""
    new_case["timeseries_data"] = timeseries_data
    new_case["obd_data"] = {"dtcs": ["P0001"]}
    new_case["symptoms"] = {
        "component": "battery",
        "label": "defect"
    }
    return new_case


class TestNewCase:

    def test_validation_fails_without_vin(self, new_case):
        with pytest.raises(ValidationError):
            new_case.pop("vehicle_vin")
            NewCase(**new_case)

    def test_default_input(self):
        # only vin required, everything else has default values
        NewCase(vehicle_vin="123")

    def test_non_default_input(self, new_case):
        NewCase(**new_case)


class TestCase:

    @pytest.mark.asyncio
    async def test_validation_fails_without_workshop_id(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            with pytest.raises(ValidationError):
                Case(**new_case)

    @pytest.mark.asyncio
    async def test_validation_with_workshop_id(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            Case(workshop_id="1", **new_case)

    @pytest.mark.asyncio
    async def test_automatic_vehicle_insert(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            # assert no vehicles yet
            all_vehicles = await Vehicle.find_all().to_list()
            assert len(all_vehicles) == 0

            # create a new case
            new_vin = new_case["vehicle_vin"]
            case = Case(workshop_id="1", **new_case)
            await case.create()

            # assert vehicle was created automatically
            all_vehicles = await Vehicle.find_all().to_list()
            assert len(all_vehicles) == 1
            created_vehicle = all_vehicles[0]
            assert created_vehicle.vin == new_vin

    @pytest.mark.asyncio
    async def test_find_in_hub_default(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            # no cases yet, empty list expected
            all_cases = await Case.find_in_hub()
            assert len(all_cases) == 0

            # insert a case
            await Case(workshop_id="1", **new_case).create()

            # find_in_hub without args should work and return all cases
            all_cases = await Case.find_in_hub()
            assert len(all_cases) == 1

    @pytest.mark.asyncio
    async def test_find_in_hub(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            # three cases are identical at the beginning
            new_case["workshop_id"] = "1"
            case_1 = dict(**new_case)
            case_2 = dict(**new_case)
            case_3 = dict(**new_case)

            # alter customer for case 1 and create
            case_1_customer_id = "5eb7cf5a86d9755df3a6c593"
            case_1["customer_id"] = case_1_customer_id
            case_1 = Case(**case_1)
            await case_1.create()

            # alter vin for case 2 and create
            case_2_vin = "Case 2 VIN"
            case_2["vehicle_vin"] = case_2_vin
            case_2 = Case(**case_2)
            await case_2.create()

            # alter workshop for case 3 and create
            case_3_workshop_id = "Case 3 Workshop ID"
            case_3["workshop_id"] = case_3_workshop_id
            case_3 = Case(**case_3)
            await case_3.create()

            # filter condition should only match case 1
            case_1_result = await Case.find_in_hub(
                customer_id=case_1_customer_id
            )
            # filter condition should only match case 2
            case_2_result = await Case.find_in_hub(
                vin=case_2_vin
            )
            # filter condition should only match case 3
            case_3_result = await Case.find_in_hub(
                workshop_id=case_3_workshop_id
            )

            # single case expected for each filter condition
            assert len(case_1_result) == 1
            assert len(case_2_result) == 1
            assert len(case_3_result) == 1

            # confirm expected data
            assert str(case_1_result[0].customer_id) == case_1_customer_id
            assert case_2_result[0].vehicle_vin == case_2_vin
            assert case_3_result[0].workshop_id == case_3_workshop_id

    @pytest.mark.parametrize(
        "query_vin,expected_vins",
        [
            ("AB", ["ABC", "ABCD"]),
            ("ABC", ["ABC", "ABCD"]),
            ("ABCD", ["ABCD"]),
            ("BC", [])
        ]
    )
    @pytest.mark.asyncio
    async def test_find_in_hub_with_partial_vin(
            self, initialized_beanie_context, query_vin, expected_vins
    ):
        async with initialized_beanie_context:
            workshop_id = "test-workshop"
            await Case(vehicle_vin="ABC", workshop_id=workshop_id).create()
            await Case(vehicle_vin="ABCD", workshop_id=workshop_id).create()
            await Case(vehicle_vin="ZABC", workshop_id=workshop_id).create()

            retrieved_cases = await Case.find_in_hub(vin=query_vin)
            retrieved_vins = sorted([_.vehicle_vin for _ in retrieved_cases])
            assert retrieved_vins == expected_vins

    @pytest.mark.parametrize(
        "query_dtc,expected_cases",
        [
            ("P0001", [0, 1]),
            ("Q0002", [1]),
            ("Z0001", [])
        ]
    )
    @pytest.mark.asyncio
    async def test_find_in_hub_by_obd_data_dtc(
            self, initialized_beanie_context, query_dtc, expected_cases
    ):
        async with initialized_beanie_context:
            workshop_id = "test-workshop"
            vin = "test-vin"
            # Three cases are put into the db
            cases = []
            for _ in range(3):
                case = await Case(
                    vehicle_vin=vin, workshop_id=workshop_id
                ).create()
                cases.append(case)
            # OBD data with dtcs is added to two of the three cases
            await cases[0].add_obd_data(
                NewOBDData(dtcs=["P0001"])
            )
            await cases[1].add_obd_data(
                NewOBDData(dtcs=["P0001", "Q0002"])
            )

            retrieved_cases = await Case.find_in_hub(obd_data_dtc=query_dtc)
            retrieved_case_ids = sorted([_.id for _ in retrieved_cases])
            expected_case_ids = sorted([cases[i].id for i in expected_cases])
            assert retrieved_case_ids == expected_case_ids

    @pytest.mark.parametrize("query_dtc", ["P0001", "Q0001", "Z0002"])
    @pytest.mark.asyncio
    async def test_find_in_hub_by_obd_data_dtc_with_multiple_datasets(
            self, initialized_beanie_context, query_dtc
    ):
        """Test non-standard situation with multiple obd datasets in a case."""
        async with initialized_beanie_context:
            case = await Case(workshop_id="42", vehicle_vin="42").create()
            await case.add_obd_data(
                NewOBDData(dtcs=["P0001", "Z0002"])
            )
            await case.add_obd_data(
                NewOBDData(dtcs=["Q0001", "Z0002"])
            )
            await case.add_obd_data(
                NewOBDData(dtcs=[])
            )
            retrieved_cases = await Case.find_in_hub(obd_data_dtc=query_dtc)
            assert [_.id for _ in retrieved_cases] == [case.id]

    @pytest.mark.parametrize(
        "query_component,expected_cases",
        [
            ("Comp-A", [0, 1]),
            ("Comp-B", [1]),
            ("Comp-C", [])
        ]
    )
    @pytest.mark.asyncio
    async def test_find_in_hub_by_timeseries_data_component(
            self,
            monkeypatch,
            initialized_beanie_context,
            query_component,
            expected_cases
    ):
        # Patch to_timeseries_data to avoid signal store configuration
        async def mock_to_timeseries_data(self):
            # Just exchange signal for signal_id without storing the signal
            meta_data = self.model_dump(exclude={"signal"})
            meta_data["signal_id"] = ObjectId()
            return TimeseriesData(**meta_data)

        monkeypatch.setattr(
            NewTimeseriesData, "to_timeseries_data", mock_to_timeseries_data
        )

        async with initialized_beanie_context:
            workshop_id = "test-workshop"
            vin = "test-vin"
            # Three cases are put into the db
            cases = []
            for _ in range(3):
                case = await Case(
                    vehicle_vin=vin, workshop_id=workshop_id
                ).create()
                cases.append(case)

            common_kwargs = {
                "signal": [.42],
                "sampling_rate": 1,
                "duration": 1,
                "label": "unknown"
            }
            # One dataset is added to first case
            await cases[0].add_timeseries_data(
                NewTimeseriesData(component="Comp-A", **common_kwargs)
            )
            # Two datasets are added to second case
            await cases[1].add_timeseries_data(
                NewTimeseriesData(component="Comp-B", **common_kwargs)
            )
            await cases[1].add_timeseries_data(
                NewTimeseriesData(component="Comp-A", **common_kwargs)
            )

            retrieved_cases = await Case.find_in_hub(
                timeseries_data_component=query_component
            )
            retrieved_case_ids = sorted([_.id for _ in retrieved_cases])
            expected_case_ids = sorted([cases[i].id for i in expected_cases])
            assert retrieved_case_ids == expected_case_ids

    @pytest.mark.asyncio
    async def test_data_counter_are_correctly_initilialized(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            # confirm that all dataset counters are initilized with 0
            assert case.timeseries_data_added == 0
            assert case.obd_data_added == 0
            assert case.symptoms_added == 0

    @pytest.mark.asyncio
    async def test_add_timeseries_data(
            self, new_case, initialized_beanie_context
    ):

        test_signal_id = "5eb7cf5a86d9755df3a6c593"

        new_timeseries_data = {
            "component": "battery",
            "label": "unknown",
            "sampling_rate": 1,
            "duration": 2,
            "type": "oscillogram",
            "signal": [42., 99.]
        }

        class MockNewTimeseriesData(NewTimeseriesData):
            """
            A mock for NewTimeseriesData that does not interact with a
            signal store when executing to_timeseries_data.
            """

            async def to_timeseries_data(self):
                signal_id = test_signal_id
                meta_data = self.model_dump(exclude={"signal"})
                meta_data["signal_id"] = signal_id
                return TimeseriesData(**meta_data)

        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            # specify non-zero number of previous additions of datasets
            previous_adds = 10
            case.timeseries_data_added = previous_adds

            # Case.add_timeseries_data calls arguments .to_timeseries_data
            # method. Hence, pass instance of the mock class, to avoid
            # configuration of a signal store backend
            new_data = MockNewTimeseriesData(**new_timeseries_data)
            await case.add_timeseries_data(new_data)

            # refetch case and assert existence of single timeseries with
            # expected signal_id
            case_retrieved = await Case.get(case.id)
            assert case_retrieved is not None
            assert len(case_retrieved.timeseries_data) == 1
            timeseries_data_retrieved = case_retrieved.timeseries_data[0]
            assert str(timeseries_data_retrieved.signal_id) == test_signal_id

            # confirm that previous timeseries_data_added is used as data id
            assert case.timeseries_data[0].data_id == previous_adds
            assert case_retrieved.timeseries_data[0].data_id == previous_adds

            # confirm increment of counter for instance and db
            assert case.timeseries_data_added == previous_adds + 1
            assert case_retrieved.timeseries_data_added == previous_adds + 1

    @pytest.mark.asyncio
    async def test_add_obd_data(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            # specify non-zero number of previous additions of datasets
            previous_adds = 10
            case.obd_data_added = previous_adds

            await case.add_obd_data(
                NewOBDData(dtcs=["P0001", "U0001"])
            )

            # refetch case and assert existence of single obd_data set
            case_retrieved = await Case.get(case.id)
            assert case_retrieved is not None
            assert len(case_retrieved.obd_data) == 1

            # confirm that previous obd_data_added is used as data id
            assert case.obd_data[0].data_id == previous_adds
            assert case_retrieved.obd_data[0].data_id == previous_adds

            # confirm increment of counter for instance and db
            assert case.obd_data_added == previous_adds + 1
            assert case_retrieved.obd_data_added == previous_adds + 1

    @pytest.mark.asyncio
    async def test_add_symptom(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            # specify non-zero number of previous additions of datasets
            previous_adds = 10
            case.symptoms_added = previous_adds

            await case.add_symptom(
                NewSymptom(
                    **{
                        "component": "battery",
                        "label": SymptomLabel("defect")
                    }
                    )
            )

            # refetch case and assert existence of single symptom
            case_retrieved = await Case.get(case.id)
            assert case_retrieved is not None
            assert len(case_retrieved.symptoms) == 1

            # confirm that previous symptoms_added is used as data id
            assert case.symptoms[0].data_id == previous_adds
            assert case_retrieved.symptoms[0].data_id == previous_adds

            # confirm increment of counter for instance and db
            assert case.symptoms_added == previous_adds + 1
            assert case_retrieved.symptoms_added == previous_adds + 1

    @pytest.mark.asyncio
    async def test_get_timeseries_data_non_existent(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            retrieved_timeseries_data = case.get_timeseries_data(0)
            assert retrieved_timeseries_data is None

    @pytest.mark.asyncio
    async def test_get_timeseries_data(
            self, new_case, timeseries_data, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            data_id = 14
            timeseries_data["data_id"] = data_id
            new_case["timeseries_data"] = [timeseries_data]
            case = Case(workshop_id="1", **new_case)
            retrieved_timeseries_data = case.get_timeseries_data(data_id)
            assert retrieved_timeseries_data
            assert str(retrieved_timeseries_data.signal_id) == \
                   timeseries_data["signal_id"]

    @pytest.mark.asyncio
    async def test_get_obd_data_non_existent(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            retrieved_obd_data = case.get_obd_data(0)
            assert retrieved_obd_data is None

    @pytest.mark.asyncio
    async def test_get_obd_data(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            data_id = 2
            dtcs = ["P0001", "U0001"]
            new_case["obd_data"] = [{"dtcs": dtcs, "data_id": 2}]
            case = Case(workshop_id="1", **new_case)
            retrieved_obd_data = case.get_obd_data(data_id)
            assert retrieved_obd_data
            assert retrieved_obd_data.dtcs == dtcs

    @pytest.mark.asyncio
    async def test_get_symptom_non_existent(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            retrieved_symptom = case.get_symptom(0)
            assert retrieved_symptom is None

    @pytest.mark.asyncio
    async def test_get_symptom(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            data_id = 5
            symptom = {
                "component": "battery", "label": "defect", "data_id": data_id
            }
            new_case["symptoms"] = [symptom]
            case = Case(workshop_id="1", **new_case)
            retrieved_symptom = case.get_symptom(data_id)
            assert retrieved_symptom
            dump = retrieved_symptom.model_dump(exclude={"timestamp"})
            assert dump == symptom

    @pytest.mark.asyncio
    async def test_delete_timeseries_data_non_existent(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            await case.delete_timeseries_data(0)

    @mock.patch(
        "api.data_management.case.TimeseriesData.delete_signal", autospec=True
    )
    @pytest.mark.asyncio
    async def test_delete_timeseries_data(
            self,
            delete_signal,
            new_case,
            timeseries_data,
            initialized_beanie_context
    ):

        # patch TimeseriesData.delete_signal
        delete_signal.side_effect = mock.AsyncMock()

        async with initialized_beanie_context:
            data_id = 3
            timeseries_data["data_id"] = data_id

            # seed case with timeseries_data and save to db
            new_case["timeseries_data"] = [timeseries_data]
            case = Case(workshop_id="1", **new_case)
            await case.save()

            # delete and confirm removal from instance
            await case.delete_timeseries_data(data_id)
            assert case.timeseries_data == []

            # refetch case and assert deletion in database
            case_retrieved = await Case.get(case.id)
            assert case_retrieved is not None
            assert case_retrieved.timeseries_data == []

            # confirm that TimeseriesData.delete_signal was awaited
            delete_signal.assert_awaited()

    @pytest.mark.asyncio
    async def test_delete_obd_data_non_existent(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            await case.delete_obd_data(0)

    @pytest.mark.asyncio
    async def test_delete_obd_data(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            data_id = 1

            # seed case with obd_data and save to db
            dtcs = ["P0001", "U0001"]
            new_case["obd_data"] = [{"dtcs": dtcs, "data_id": data_id}]
            case = Case(workshop_id="1", **new_case)
            await case.save()

            # delete and confirm removal from instance
            await case.delete_obd_data(data_id)
            assert case.obd_data == []

            # refetch case and assert deletion in database
            case_retrieved = await Case.get(case.id)
            assert case_retrieved is not None
            assert case_retrieved.obd_data == []

    @pytest.mark.asyncio
    async def test_delete_symptom_non_existent(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            await case.delete_symptom(0)

    @pytest.mark.asyncio
    async def test_delete_symptoms(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            data_id = 20

            # seed case with symptom and save to db
            symptom = {
                "component": "battery", "label": "defect", "data_id": data_id
            }
            new_case["symptoms"] = [symptom]
            case = Case(workshop_id="1", **new_case)
            await case.save()

            # delete and confirm removal from instance
            await case.delete_symptom(data_id)
            assert case.symptoms == []

            # refetch case and assert deletion in database
            case_retrieved = await Case.get(case.id)
            assert case_retrieved is not None
            assert case_retrieved.symptoms == []

    @pytest.mark.asyncio
    async def test_update_timeseries_data_non_existent(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            timeseries_data = await case.update_timeseries_data(
                0, update=TimeseriesDataUpdate()
            )
            assert timeseries_data is None

    @pytest.mark.asyncio
    async def test_update_timeseries_data(
            self,
            new_case,
            timeseries_data,
            initialized_beanie_context
    ):
        async with initialized_beanie_context:
            data_id = 42
            old_label = "unknown"
            new_label = "anomaly"
            timeseries_data["label"] = old_label
            timeseries_data["data_id"] = data_id

            # seed case with timeseries datasets that has old label
            new_case["timeseries_data"] = [timeseries_data]
            case = Case(workshop_id="1", **new_case)
            await case.save()

            # update the timeseries dataset with new_label
            update = TimeseriesDataUpdate(label=TimeseriesDataLabel(new_label))
            await case.update_timeseries_data(data_id=data_id, update=update)

            # confirm correct update of instance
            assert case.timeseries_data[0].label == new_label

            # refetch case and assert update in database
            case_retrieved = await Case.get(case.id)
            assert case_retrieved is not None
            assert case_retrieved.timeseries_data[0].label == new_label

    @pytest.mark.asyncio
    async def test_update_obd_data_non_existent(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            obd_data = await case.update_obd_data(0, update=OBDDataUpdate())
            assert obd_data is None

    @pytest.mark.asyncio
    async def test_update_obd_data(
            self,
            new_case,
            initialized_beanie_context
    ):
        async with initialized_beanie_context:
            data_id = 33
            obd_data = {"dtcs": ["P0001", "U0001"], "data_id": data_id}

            old_specs = {}
            new_specs = {"firmware version": 1.0}
            obd_data["obd_specs"] = old_specs

            # seed case with obd dataset that has old specs
            new_case["obd_data"] = [obd_data]
            case = Case(workshop_id="1", **new_case)
            await case.save()

            # update obd dataset with new_specs
            update = OBDDataUpdate(obd_specs=new_specs)
            await case.update_obd_data(data_id=data_id, update=update)

            # confirm correct update of instance
            assert case.obd_data[0].obd_specs == new_specs

            # refetch case and assert update in database
            case_retrieved = await Case.get(case.id)
            assert case_retrieved is not None
            assert case_retrieved.obd_data[0].obd_specs == new_specs

    @pytest.mark.asyncio
    async def test_update_symptom_non_existent(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            case = Case(workshop_id="1", **new_case)
            assert await case.update_symptom(0, update=SymptomUpdate()) is None

    @pytest.mark.asyncio
    async def test_update_symptom(
            self,
            new_case,
            initialized_beanie_context
    ):
        async with initialized_beanie_context:
            data_id = 100
            symptom = {"component": "battery", "data_id": data_id}
            old_label = "unknown"
            new_label = "defect"
            symptom["label"] = old_label

            # seed case with symptom that has old label
            new_case["symptoms"] = [symptom]
            case = Case(workshop_id="1", **new_case)
            await case.save()

            # update symptom with new_label
            update = SymptomUpdate(label=SymptomLabel(new_label))
            await case.update_symptom(data_id=data_id, update=update)

            # confirm correct update of instance
            assert case.symptoms[0].label == new_label

            # refetch case and assert update in database
            case_retrieved = await Case.get(case.id)
            assert case_retrieved is not None
            assert case_retrieved.symptoms[0].label == new_label

    @pytest.mark.asyncio
    async def test_available_timeseries_data(
            self, new_case, timeseries_data, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            data_ids = [0, 42]
            ts_data_1 = dict(**timeseries_data, data_id=data_ids[0])
            ts_data_2 = dict(**timeseries_data, data_id=data_ids[1])
            new_case["timeseries_data"] = [ts_data_1, ts_data_2]
            case = Case(workshop_id="1", **new_case)
            assert case.available_timeseries_data == data_ids

    @pytest.mark.asyncio
    async def test_available_obd_data(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            data_ids = [0, 42]
            new_case["obd_data"] = [
                {"dtcs": ["P0000"], "data_id": d_id}
                for d_id in data_ids
            ]
            case = Case(workshop_id="1", **new_case)
            assert case.available_obd_data == data_ids

    @pytest.mark.asyncio
    async def test_available_symptoms(
            self, new_case, initialized_beanie_context
    ):
        async with initialized_beanie_context:
            data_ids = [0, 42]
            new_case["symptoms"] = [
                {"component": "battery", "label": "defect", "data_id": d_id}
                for d_id in data_ids
            ]
            case = Case(workshop_id="1", **new_case)
            assert case.available_symptoms == data_ids

    @mock.patch(
        "api.data_management.case.TimeseriesData.delete_signal", autospec=True
    )
    @pytest.mark.asyncio
    async def test_delete_all_timeseries_signals(
            self,
            delete_signal,
            new_case,
            timeseries_data,
            initialized_beanie_context
    ):

        # patch TimeseriesData.delete_signal
        delete_signal.side_effect = mock.AsyncMock()

        async with initialized_beanie_context:
            # seed case with timeseries_data and save to db
            new_case["timeseries_data"] = [
                timeseries_data, timeseries_data
            ]
            case = Case(workshop_id="1", **new_case)
            await case.save()
            await case._delete_all_timeseries_signals()

            # delete_signal should have been awaited for each not entry
            assert delete_signal.await_count == 2
