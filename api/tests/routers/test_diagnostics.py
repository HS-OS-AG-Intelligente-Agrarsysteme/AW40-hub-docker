import pytest
from api.data_management import (
    Case, NewOBDData, NewSymptom, NewTimeseriesData,
    TimeseriesMetaData, Action, AttachmentBucket, Diagnosis
)
from api.data_management.timeseries_data import GridFSSignalStore
from api.routers import diagnostics
from bson import ObjectId
from fastapi import FastAPI
from httpx import AsyncClient
from motor import motor_asyncio


@pytest.fixture
def diag_id():
    return str(ObjectId())


@pytest.fixture
def case_id():
    return str(ObjectId())


@pytest.fixture
def data_context(diag_id, case_id):
    # Prefill database with diagnosis and associated case.
    # Usage: `with initialized_beanie_context, data_context: ...`
    # Within each test, the created objects will have the ids specified by
    # the diag_id and case_id fixtures.
    class DataContext:
        async def __aenter__(self):
            await Diagnosis(id=diag_id, case_id=case_id).create()
            await Case(
                id=case_id,
                diagnosis_id=diag_id,
                vehicle_vin="test-vin",
                workshop_id="test-workshop"
            ).create()

        async def __aexit__(self, exc_type, exc, tb):
            pass

    return DataContext()


test_app = FastAPI()
test_app.include_router(diagnostics.router)

client = AsyncClient(app=test_app, base_url="http://")


@pytest.mark.asyncio
async def test_get_diagnosis(
        diag_id, case_id, data_context, initialized_beanie_context
):
    async with initialized_beanie_context, data_context:
        response = await client.get(f"{diag_id}")
        assert response.status_code == 200
        assert response.json()["case_id"] == case_id


@pytest.mark.asyncio
async def test_get_diagnosis_404(diag_id, initialized_beanie_context):
    async with initialized_beanie_context:
        response = await client.get(f"{diag_id}")
        assert response.status_code == 404


@pytest.mark.asyncio
async def test_get_obd_data(
        diag_id, case_id, data_context, initialized_beanie_context
):
    async with initialized_beanie_context, data_context:
        case = await Case.get(case_id)
        obd_data = {"dtcs": ["P1234"]}
        await case.add_obd_data(
            NewOBDData(**obd_data)
        )

        response = await client.get(f"/{diag_id}/obd_data")
        assert response.status_code == 200
        assert response.json()[0]["dtcs"] == obd_data["dtcs"]


@pytest.mark.asyncio
async def test_get_obd_data_no_data(
        diag_id, case_id, data_context, initialized_beanie_context
):
    async with initialized_beanie_context, data_context:
        # Requesting data for case without data should return an empty
        # array in response
        response = await client.get(
            f"/{diag_id}/obd_data"
        )
        # confirm expected response
        assert response.status_code == 200
        assert response.json() == []


@pytest.mark.asyncio
async def test_get_obd_data_404(diag_id, initialized_beanie_context):
    async with initialized_beanie_context:
        response = await client.get(f"{diag_id}/obd_data")
        assert response.status_code == 404


@pytest.mark.asyncio
async def test_get_vehicle(
        diag_id, case_id, data_context, initialized_beanie_context
):
    async with initialized_beanie_context, data_context:
        case = await Case.get(case_id)
        response = await client.get(
            f"/{diag_id}/vehicle"
        )
        # confirm expected response
        assert response.status_code == 200
        assert response.json()["vin"] == case.vehicle_vin


@pytest.mark.asyncio
async def test_get_vehicle_404(diag_id, initialized_beanie_context):
    async with initialized_beanie_context:
        response = await client.get(f"{diag_id}/vehicle")
        assert response.status_code == 404


@pytest.mark.asyncio
async def test_get_oscillograms(
        diag_id,
        case_id,
        data_context,
        initialized_beanie_context,
        signal_bucket
):
    async with initialized_beanie_context, data_context:
        # initialize gridfs signal storage for the test database
        TimeseriesMetaData.signal_store = GridFSSignalStore(signal_bucket)

        # seed database with oscillogram data
        case = await Case.get(case_id)
        component = "battery"
        oscillogram_data = {
            "signal": [42, 43],
            "component": component,
            "label": "unknown",
            "sampling_rate": 1,
            "duration": 2
        }
        await case.add_timeseries_data(
            NewTimeseriesData(**oscillogram_data)
        )

        # request oscillogram data
        client = AsyncClient(app=test_app, base_url="http://")
        response = await client.get(
            f"/{diag_id}/oscillograms?component={component}"
        )
        # confirm expected response
        assert response.status_code == 200
        assert response.json()[0]["signal"] == oscillogram_data["signal"]


@pytest.mark.asyncio
async def test_get_oscillograms_no_data(
        diag_id, case_id, data_context, initialized_beanie_context
):
    async with initialized_beanie_context, data_context:
        # Requesting data for case without data should return an empty
        # array in response
        response = await client.get(
            f"/{diag_id}/oscillograms?component=battery"
        )
        # confirm expected response
        assert response.status_code == 200
        assert response.json() == []


@pytest.mark.asyncio
async def test_get_oscillograms_404(diag_id, initialized_beanie_context):
    async with initialized_beanie_context:
        response = await client.get(f"{diag_id}/oscillograms")
        assert response.status_code == 404


@pytest.mark.asyncio
async def test_get_symptoms(
        diag_id, case_id, data_context, initialized_beanie_context
):
    async with initialized_beanie_context, data_context:
        # seed database with data
        component = "battery"
        symptom_data = {
            "component": component,
            "label": "defect"
        }
        case = await Case.get(case_id)
        await case.add_symptom(
            NewSymptom(**symptom_data)
        )

        # request data
        response = await client.get(
            f"/{diag_id}/symptoms?component={component}"
        )
        # confirm expected response
        assert response.status_code == 200
        assert response.json()[0]["label"] == symptom_data["label"]


@pytest.mark.asyncio
async def test_get_symptoms_no_data(
        diag_id, data_context, initialized_beanie_context
):
    async with initialized_beanie_context, data_context:
        # Requesting data for case without data should return an empty
        # array in response
        response = await client.get(
            f"/{diag_id}/symptoms?component=battery"
        )
        # confirm expected response
        assert response.status_code == 200
        assert response.json() == []


@pytest.mark.asyncio
async def test_get_symptoms_404(diag_id, initialized_beanie_context):
    async with initialized_beanie_context:
        response = await client.get(f"{diag_id}/symptoms")
        assert response.status_code == 404


@pytest.mark.asyncio
async def test_create_todo(diag_id, data_context, initialized_beanie_context):
    async with initialized_beanie_context, data_context:

        new_action_data = {
            "id": "add-data-obd",
            "instruction": "Bitte OBD Daten erstellen und hochladen.",
            "action_type": "add_data",
            "data_type": "obd",
            "component": None
        }

        # test request
        response = await client.put(
            f"{diag_id}/todos/{new_action_data['id']}", json=new_action_data
        )

        # confirm expected response data
        assert response.status_code == 201
        response_data = response.json()
        assert response_data["_id"] == diag_id
        assert response_data["todos"][-1] == new_action_data

        # confirm expected new state in db
        diag = await Diagnosis.get(response_data["_id"])
        assert diag.todos[-1] == Action(**new_action_data)


@pytest.mark.asyncio
async def test_create_todo_no_diag_404(diag_id, initialized_beanie_context):
    async with initialized_beanie_context:
        response = await client.put(f"{diag_id}/todos/a-id")
        assert response.status_code == 404


@pytest.mark.asyncio
async def test_delete_todo(diag_id, data_context, initialized_beanie_context):
    async with initialized_beanie_context, data_context:
        # seed db diagnosis with an action
        diag = await Diagnosis.get(diag_id)
        action_id = "test-action"
        diag.todos.append(Action(id=action_id, instruction="Do something"))
        await diag.save()

        # test response
        response = await client.delete(f"{diag_id}/todos/{action_id}")

        # confirm expected response data
        assert response.status_code == 200
        assert response.json() is None

        # confirm expected new state in db
        diag = await Diagnosis.get(diag_id)
        assert diag.todos == []


@pytest.mark.asyncio
async def test_delete_non_existent_todo(
        diag_id, data_context, initialized_beanie_context
):
    async with initialized_beanie_context, data_context:
        response = await client.delete(f"{diag_id}/todos/action-id")
        assert response.status_code == 200
        assert response.json() is None


@pytest.mark.asyncio
async def test_add_message_to_state_machine_log_no_attachment(
        diag_id, data_context, initialized_beanie_context, motor_db
):
    # initialize gridfs attachment storage for the test database
    AttachmentBucket.bucket = motor_asyncio.AsyncIOMotorGridFSBucket(
        motor_db, bucket_name="attachments"
    )

    async with initialized_beanie_context, data_context:
        # execute test request
        msg = "This is a test"
        response = await client.post(
            f"{diag_id}/state-machine-log",
            data={"message": msg}
        )
        # confirm expected response data
        assert response.status_code == 201
        response_data = response.json()
        assert response_data[-1]["message"] == msg
        assert response_data[-1]["attachment"] is None

        # confirm expected change of db state
        diag = await Diagnosis.get(diag_id)
        assert diag.state_machine_log[-1].message == msg


@pytest.mark.asyncio
async def test_add_message_to_state_machine_log_with_attachment(
        diag_id, data_context, initialized_beanie_context, motor_db
):
    # initialize gridfs attachment storage for the test database
    AttachmentBucket.bucket = motor_asyncio.AsyncIOMotorGridFSBucket(
        motor_db, bucket_name="attachments"
    )

    async with initialized_beanie_context, data_context:
        # execute test request
        msg = "This is a test"
        attachment_content = b"test content"
        response = await client.post(
            f"{diag_id}/state-machine-log",
            data={"message": msg},
            files={"attachment": attachment_content}
        )
        # confirm expected response data
        assert response.status_code == 201
        response_data = response.json()
        assert response_data[-1]["message"] == msg

        # confirm expected change of db state
        diag = await Diagnosis.get(diag_id)
        assert diag.state_machine_log[-1].message == msg

        attachment_id = response_data[-1]["attachment"]
        assert str(diag.state_machine_log[-1].attachment) == attachment_id

        bucket_stream = await AttachmentBucket.bucket.open_download_stream(
            ObjectId(attachment_id)
        )
        bucket_content = await bucket_stream.read()
        assert bucket_content == attachment_content


@pytest.mark.asyncio
async def test_add_message_to_state_machine_log_404(
        diag_id, initialized_beanie_context
):
    async with initialized_beanie_context:
        response = await client.post(f"{diag_id}/state-machine-log")
        assert response.status_code == 404


@pytest.mark.asyncio
async def test_set_state_machine_status(
        diag_id, data_context, initialized_beanie_context
):
    new_status = "processing"
    async with initialized_beanie_context, data_context:
        # double check that diag in data_context does not have the new status
        diag = await Diagnosis.get(diag_id)
        assert diag.status != new_status

        # test request and confirm expected response data
        response = await client.put(f"{diag_id}/status", json=new_status)
        assert response.status_code == 201
        assert response.json() == new_status

        # confirm expected state in db
        diag = await Diagnosis.get(diag_id)
        assert diag.status == new_status


@pytest.mark.asyncio
async def test_set_state_machine_status_404(
        diag_id, initialized_beanie_context
):
    async with initialized_beanie_context:
        response = await client.put(f"{diag_id}/status")
        assert response.status_code == 404
