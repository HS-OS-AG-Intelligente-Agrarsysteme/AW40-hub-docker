from typing import List, Union

from bson import ObjectId
from fastapi import (
    APIRouter, HTTPException, Body, Form, Depends, UploadFile, File
)
from motor import motor_asyncio

from ..data_management import (
    Case,
    Diagnosis,
    DiagnosisStatus,
    DiagnosisLogEntry,
    OBDData,
    Vehicle,
    Symptom,
    AttachmentBucket,
    TimeseriesDataFull,
    Action
)
from ..security.api_key_auth import APIKeyAuth

tags_metadata = [
    {
        "name": "Diagnostics",
        "description": "Endpoints for the AI based diagnostics backend"
    }
]

api_key_auth = APIKeyAuth()

router = APIRouter(tags=["Diagnostics"], dependencies=[Depends(api_key_auth)])


async def _diag_by_id_or_404(diag_id: str):
    diag = await Diagnosis.get(diag_id)
    if diag is None:
        raise HTTPException(
            status_code=404, detail=f"No diagnosis with ID '{diag_id}'"
        )
    return diag


async def _case_by_diag_id_or_404(diag_id: str):
    case = await Case.find_one({"diagnosis_id": ObjectId(diag_id)})
    if case is None:
        raise HTTPException(
            status_code=404, detail=f"No diagnosis with ID '{diag_id}'"
        )
    return case


@router.get(
    "/{diag_id}",
    status_code=200,
    response_model=Diagnosis
)
async def get_diagnosis(diag: Diagnosis = Depends(_diag_by_id_or_404)):
    """Get data of a diagnosis."""
    return diag


@router.get(
    "/{diag_id}/obd_data",
    status_code=200,
    response_model=List[OBDData]
)
async def get_obd_data(case: Case = Depends(_case_by_diag_id_or_404)):
    """Get OBD data for a diagnosis."""
    return case.obd_data


@router.get(
    "/{diag_id}/vehicle",
    status_code=200,
    response_model=Vehicle
)
async def get_vehicle(case: Case = Depends(_case_by_diag_id_or_404)):
    """Get vehicle data for a diagnosis."""
    vehicle = await Vehicle.find_one({"vin": case.vehicle_vin})
    return vehicle


@router.get(
    "/{diag_id}/oscillograms",
    status_code=200,
    response_model=List[TimeseriesDataFull]
)
async def get_oscillograms(
        component: str,
        case: Case = Depends(_case_by_diag_id_or_404)
):
    """Get all oscillograms for a specific component."""
    output_data = []
    for tsd in case.timeseries_data:
        if tsd.component == component:
            signal = await tsd.get_signal()
            output_data.append(
                TimeseriesDataFull(signal=signal, **tsd.dict())
            )
    return output_data


@router.get(
    "/{diag_id}/symptoms",
    status_code=200,
    response_model=List[Symptom]
)
async def get_symptoms(
        component: str, case: Case = Depends(_case_by_diag_id_or_404)
):
    """Get all symptoms for a specific component."""
    symptoms = [s for s in case.symptoms if s.component == component]
    return symptoms


@router.put(
    "/{diag_id}/todos/{action_id}",
    status_code=201,
    response_model=Diagnosis
)
async def set_todo(
        action_id: str,
        action: Action,
        diag: Diagnosis = Depends(_diag_by_id_or_404)
):
    """Require a user action for a diagnosis."""
    action.id = action_id
    todo_exists = False
    # if action with same id exists in todos, replace it
    for i, todo in enumerate(diag.todos):
        if todo.id == action_id:
            diag.todos[i] = action
            todo_exists = True
            break
    # if action not yet in todos, create it
    if not todo_exists:
        diag.todos.append(action)
    await diag.save()
    return diag


@router.delete(
    "/{diag_id}/todos/{action_id}",
    status_code=200,
    response_model=None
)
async def delete_todo(
        action_id: str, diag: Diagnosis = Depends(_diag_by_id_or_404)
):
    """Remove a required user action from a diagnosis."""
    for i, todo in enumerate(diag.todos):
        if todo.id == action_id:
            diag.todos.pop(i)
            break
    await diag.save()
    return None


@router.post(
    "/{diag_id}/state-machine-log",
    status_code=201,
    response_model=List[DiagnosisLogEntry]
)
async def add_message_to_state_machine_log(
        message: str = Form(title="Message to be added to log."),
        attachment: Union[UploadFile, None] = File(default=None),
        diag: Diagnosis = Depends(_diag_by_id_or_404),
        attachment_bucket: motor_asyncio.AsyncIOMotorGridFSBucket = Depends(
            AttachmentBucket.create
        )
):
    attachment_id = None
    # if a file attachments was uploaded, store it and generate an id
    if attachment is not None:
        attachment_content = await attachment.read()
        attachment_id = await attachment_bucket.upload_from_stream(
            filename=attachment.filename,
            source=attachment_content
        )

    new_log_entry = DiagnosisLogEntry(
        message=message,
        attachment=attachment_id
    )
    diag.state_machine_log.append(new_log_entry)
    await diag.save()
    return diag.state_machine_log


@router.put(
    "/{diag_id}/status",
    status_code=201,
    response_model=DiagnosisStatus
)
async def set_state_machine_status(
        status: DiagnosisStatus = Body(title="New status"),
        diag: Diagnosis = Depends(_diag_by_id_or_404)
):
    diag.status = status
    await diag.save()
    return diag.status
