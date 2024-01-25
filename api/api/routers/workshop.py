from typing import List, Union, Literal, Optional

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import (
    APIRouter, HTTPException, Depends, UploadFile, File, Form
)
from fastapi.responses import Response
from motor import motor_asyncio
from pydantic import NonNegativeInt, PositiveInt

from ..data_management import (
    NewCase,
    Case,
    CaseUpdate,
    NewOBDData,
    OBDDataUpdate,
    OBDData,
    NewSymptom,
    Symptom,
    SymptomUpdate,
    TimeseriesDataUpdate,
    NewTimeseriesData,
    TimeseriesData,
    TimeseriesDataLabel,
    Vehicle,
    VehicleUpdate,
    Customer,
    Diagnosis,
    DiagnosisStatus,
    AttachmentBucket
)
from ..diagnostics_management import DiagnosticTaskManager
from ..security.token_auth import authorized_workshop_id
from ..upload_filereader import filereader_factory, FileReaderException

tags_metadata = [
    {
        "name": "Workshop - Case Management",
        "description": "Manage cases and associated meta data of a workshop."
    },
    {
        "name": "Workshop - Data Management",
        "description": "Manage diagnostic data of a specific case."
    },
    {
        "name": "Workshop - Diagnostics",
        "description": "Manage diagnosis of a case."
    }
]

router = APIRouter(dependencies=[Depends(authorized_workshop_id)])


@router.get(
    "/{workshop_id}/cases",
    status_code=200,
    response_model=List[Case],
    tags=["Workshop - Case Management"]
)
async def list_cases(
        workshop_id: str, customer_id: str = None, vin: str = None
) -> List[Case]:
    cases = await Case.find_in_hub(
        customer_id=customer_id, vin=vin, workshop_id=workshop_id
    )
    return cases


@router.post(
    "/{workshop_id}/cases",
    status_code=201,
    response_model=Case,
    tags=["Workshop - Case Management"]
)
async def add_case(workshop_id: str, case: NewCase) -> Case:
    case = Case(workshop_id=workshop_id, **case.dict())
    case = await case.insert()
    return case


async def case_from_workshop(workshop_id: str, case_id: str) -> Case:
    """
    Shared dependency for all endpoints with path root
    '/{workshop_id}/cases/{case_id}'. Returns the case with id {case_id} if it
     exists AND the respective case belongs to the workshop specified via
     {workshop_id}. Otherwise a 404 Not Found is raised.
    """

    no_case_with_id_exception = HTTPException(
        status_code=404,
        detail=f"No case with id '{case_id}' found "
               f"for workshop '{workshop_id}'."
    )

    try:
        case_id = ObjectId(case_id)
    except InvalidId:
        # invalid id reports not found to user
        raise no_case_with_id_exception

    case = await Case.get(case_id)

    if case is None or case.workshop_id != workshop_id:
        # No case for THIS workshop
        raise no_case_with_id_exception
    else:
        return case


@router.get(
    "/{workshop_id}/cases/{case_id}",
    status_code=200,
    response_model=Case,
    tags=["Workshop - Case Management"]
)
async def get_case(case: Case = Depends(case_from_workshop)) -> Case:
    return case


@router.put(
    "/{workshop_id}/cases/{case_id}",
    status_code=200,
    tags=["Workshop - Case Management"]
)
async def update_case(
        update: CaseUpdate,
        case: Case = Depends(case_from_workshop)
):
    await case.set(update.dict(exclude_unset=True))
    return case


@router.delete(
    "/{workshop_id}/cases/{case_id}",
    status_code=200,
    response_model=None,
    tags=["Workshop - Case Management"]
)
async def delete_case(case: Case = Depends(case_from_workshop)):
    await case.delete()


@router.get(
    "/{workshop_id}/cases/{case_id}/customer",
    status_code=200,
    response_model=Customer, tags=["Workshop - Case Management"]
)
async def get_customer(case: Case = Depends(case_from_workshop)):
    customer = await Customer.get(case.customer_id)
    return customer


@router.get(
    "/{workshop_id}/cases/{case_id}/vehicle",
    status_code=200,
    response_model=Vehicle, tags=["Workshop - Case Management"]
)
async def get_vehicle(case: Case = Depends(case_from_workshop)):
    vehicle = await Vehicle.find_one({"vin": case.vehicle_vin})
    return vehicle


@router.put(
    "/{workshop_id}/cases/{case_id}/vehicle",
    status_code=200,
    response_model=Vehicle, tags=["Workshop - Case Management"]
)
async def update_vehicle(
        update: VehicleUpdate, case: Case = Depends(case_from_workshop)
):
    vehicle = await Vehicle.find_one({"vin": case.vehicle_vin})
    await vehicle.set(update.dict(exclude_unset=True))
    return vehicle


@router.get(
    "/{workshop_id}/cases/{case_id}/timeseries_data",
    status_code=200,
    response_model=List[TimeseriesData], tags=["Workshop - Data Management"]
)
def list_timeseries_data(case: Case = Depends(case_from_workshop)):
    """List all available timeseries datasets for a case."""
    return case.timeseries_data


@router.post(
    "/{workshop_id}/cases/{case_id}/timeseries_data",
    status_code=201,
    response_model=Case, tags=["Workshop - Data Management"]
)
async def add_timeseries_data(
        timeseries_data: NewTimeseriesData,
        case: Case = Depends(case_from_workshop)
) -> Case:
    """Add a new timeseries dataset to a case."""
    case = await case.add_timeseries_data(timeseries_data)
    return case


def read_file_or_400(upload: UploadFile, file_format: str) -> list:
    """
    Helper that attempts to read an uploaded file based on a user specified
    format and raises a 400 if file reading fails.
    """
    reader = filereader_factory.get_reader(file_format)
    try:
        read_result = reader.read_file(upload.file)
    except FileReaderException:
        raise HTTPException(
            status_code=400,
            detail=f"Could not read file '{upload.filename}' with file format "
                   f"'{file_format}'."
        )
    return read_result


def channel_description_form(
        component_A: str = Form(
            default=None, description="The investigated vehicle component"
        ),
        label_A: TimeseriesDataLabel = Form(
            default=TimeseriesDataLabel.unknown,
            description="Label for the oscillogram"
        ),
        component_B: str = Form(
            default=None, description="The investigated vehicle component"
        ),
        label_B: TimeseriesDataLabel = Form(
            default=TimeseriesDataLabel.unknown,
            description="Label for the oscillogram"
        ),
        component_C: str = Form(
            default=None, description="The investigated vehicle component"
        ),
        label_C: TimeseriesDataLabel = Form(
            default=TimeseriesDataLabel.unknown,
            description="Label for the oscillogram"
        ),
        component_D: str = Form(
            default=None, description="The investigated vehicle component"
        ),
        label_D: TimeseriesDataLabel = Form(
            default=TimeseriesDataLabel.unknown,
            description="Label for the oscillogram"
        )
) -> dict:
    """
    Helper to retrieve required channel descriptions for picoscope uploads.
    """
    return {
        "A": {"component": component_A, "label": label_A},
        "B": {"component": component_B, "label": label_B},
        "C": {"component": component_C, "label": label_C},
        "D": {"component": component_D, "label": label_D}
    }


def process_picoscope_upload(
        upload: UploadFile = File(description="Picoscope Data File"),
        file_format: Literal["Picoscope MAT", "Picoscope CSV"] = Form(
            default="Picoscope MAT"
        ),
        channel_description: dict = Depends(channel_description_form)
) -> list:
    """
    Helper to preprocess picoscope upload and user-provided channel
    descriptions.
    """
    # Read the uploaded file.
    read_results = read_file_or_400(upload, file_format)

    # Only select results that have a specified component.
    selected_results = []
    for channel, description in channel_description.items():
        description_component = description.get("component")
        description_label = description.get("label")
        # Channels without user specified component will be ignored.
        if description_component:
            # Component was specified for current channel. Try to find
            # a corresponding result.
            result_found = False
            for i, data in enumerate(read_results):
                if data["device_specs"]["channel"] == channel:
                    # Result found for current channel. Add descriptive
                    # attributes and move to selected_results. Break to
                    # continue with next channel.
                    result_found = True
                    data = read_results.pop(i)
                    data["component"] = description_component
                    data["label"] = description_label
                    data["type"] = "oscillogram"
                    selected_results.append(data)
                    break

            if not result_found:
                # A channel with specified component that is not found in the
                # uploaded file is a client error
                raise HTTPException(
                    status_code=400,
                    detail=f"A component was specified for channel "
                           f"'{channel}' but this channel is not found in "
                           f"file '{upload.filename}'."
                )

    return selected_results


@router.post(
    "/{workshop_id}/cases/{case_id}/timeseries_data/upload/picoscope",
    status_code=201,
    response_model=Case,
    tags=["Workshop - Data Management"]
)
async def upload_picoscope_data(
        processed_upload: list = Depends(process_picoscope_upload),
        case: Case = Depends(case_from_workshop)
):
    for data in processed_upload:
        case = await case.add_timeseries_data(
            NewTimeseriesData(**data)
        )
    return case


@router.post(
    "/{workshop_id}/cases/{case_id}/timeseries_data/upload/omniscope",
    status_code=201,
    response_model=Case,
    tags=["Workshop - Data Management"]
)
async def upload_omniscope_data(
        upload: UploadFile = File(description="Omniscope Data File"),
        file_format: Literal["Omniscope V1 RAW"] = Form(
            default="Omniscope V1 RAW"
        ),
        component: str = Form(
            description="The investigated vehicle component"
        ),
        label: TimeseriesDataLabel = Form(
            default=TimeseriesDataLabel.unknown,
            description="Label for the oscillogram"
        ),
        sampling_rate: PositiveInt = Form(
            description="Sampling rate used (Hz)"
        ),
        case: Case = Depends(case_from_workshop)
):
    reader = filereader_factory.get_reader(file_format)
    data = reader.read_file(upload.file)[0]

    if len(data["signal"]) == 0:
        raise HTTPException(
            status_code=422, detail=f"File '{upload.filename}' seems to "
                                    f"contain no data."
        )

    data["component"] = component
    data["label"] = label
    data["type"] = "oscillogram"
    data["sampling_rate"] = sampling_rate
    # duration is derived from length of signal and sampling_rate
    data["duration"] = len(data["signal"]) / sampling_rate
    case = await case.add_timeseries_data(
        NewTimeseriesData(**data)
    )
    return case


@router.get(
    "/{workshop_id}/cases/{case_id}/timeseries_data/{data_id}",
    status_code=200,
    tags=["Workshop - Data Management"]
)
async def get_timeseries_data(
        data_id: NonNegativeInt, case: Case = Depends(case_from_workshop)
) -> TimeseriesData:
    """Get a specific timeseries dataset from a case."""
    timeseries_data = case.get_timeseries_data(data_id)
    if timeseries_data is not None:
        return timeseries_data
    else:
        exception_detail = f"No timeseries_data with data_id `{data_id}` in " \
                           f"case '{case.id}'. Available data_ids are " \
                           f"{case.available_timeseries_data}."
        raise HTTPException(status_code=404, detail=exception_detail)


@router.get(
    "/{workshop_id}/cases/{case_id}/timeseries_data/{data_id}/signal",
    status_code=200,
    tags=["Workshop - Data Management"]
)
async def get_timeseries_data_signal(
        data_id: NonNegativeInt, case: Case = Depends(case_from_workshop)
) -> TimeseriesData:
    """Get the signal of a specific timeseries dataset from a case."""
    timeseries_data = case.get_timeseries_data(data_id)
    if timeseries_data is not None:
        return await timeseries_data.get_signal()
    else:
        exception_detail = f"No timeseries_data with data_id `{data_id}` in " \
                           f"case '{case.id}'. Available data_ids are " \
                           f"{case.available_timeseries_data}."
        raise HTTPException(status_code=404, detail=exception_detail)


@router.put(
    "/{workshop_id}/cases/{case_id}/timeseries_data/{data_id}",
    status_code=200,
    response_model=TimeseriesData, tags=["Workshop - Data Management"]
)
async def update_timeseries_data(
        data_id: NonNegativeInt,
        update: TimeseriesDataUpdate,
        case: Case = Depends(case_from_workshop)
):
    """Update a specific timeseries dataset of a case."""
    timeseries_data = await case.update_timeseries_data(
        data_id=data_id, update=update
    )
    if timeseries_data is not None:
        return timeseries_data
    else:
        exception_detail = f"No timeseries_data with data_id `{data_id}` in " \
                           f"case '{case.id}'. Available data_ids are " \
                           f"{case.available_timeseries_data}."
        raise HTTPException(status_code=404, detail=exception_detail)


@router.delete(
    "/{workshop_id}/cases/{case_id}/timeseries_data/{data_id}",
    status_code=200,
    response_model=Case, tags=["Workshop - Data Management"]
)
async def delete_timeseries_data(
        data_id: NonNegativeInt, case: Case = Depends(case_from_workshop)
):
    """Delete a specific timeseries dataset from a case."""
    await case.delete_timeseries_data(data_id)
    return case


@router.get(
    "/{workshop_id}/cases/{case_id}/obd_data",
    status_code=200,
    response_model=List[OBDData], tags=["Workshop - Data Management"]
)
async def list_obd_data(
        case: Case = Depends(case_from_workshop)
) -> List[OBDData]:
    """List all available obd datasets for a case."""
    return case.obd_data


@router.post(
    "/{workshop_id}/cases/{case_id}/obd_data",
    status_code=201,
    response_model=Case, tags=["Workshop - Data Management"]
)
async def add_obd_data(
        obd_data: NewOBDData,
        case: Case = Depends(case_from_workshop)
) -> Case:
    """Add a new obd dataset to a case."""
    case = await case.add_obd_data(obd_data)
    return case


@router.post(
    "/{workshop_id}/cases/{case_id}/obd_data/upload/vcds",
    status_code=201,
    response_model=Case,
    tags=["Workshop - Data Management"]
)
async def upload_vcds_data(
        upload: UploadFile = File(
            description="VCDS Data File"
        ),
        file_format: Literal["VCDS TXT"] = Form(default="VCDS TXT"),
        case: Case = Depends(case_from_workshop)
):
    data = read_file_or_400(upload, file_format)[0]
    data = data["obd_data"]
    case = await case.add_obd_data(
        NewOBDData(**data)
    )
    return case


@router.get(
    "/{workshop_id}/cases/{case_id}/obd_data/{data_id}",
    status_code=200,
    response_model=OBDData, tags=["Workshop - Data Management"]
)
async def get_obd_data(
        data_id: NonNegativeInt, case: Case = Depends(case_from_workshop)
) -> OBDData:
    """Get a specific obd dataset from a case."""
    obd_data = case.get_obd_data(data_id)
    if obd_data is not None:
        return obd_data
    else:
        exception_detail = f"No obd_data with data_id `{data_id}` in " \
                           f"case '{case.id}'. Available data_ids are " \
                           f"{case.available_obd_data}."
        raise HTTPException(status_code=404, detail=exception_detail)


@router.put(
    "/{workshop_id}/cases/{case_id}/obd_data/{data_id}",
    status_code=200,
    response_model=OBDData, tags=["Workshop - Data Management"]
)
async def update_obd_data(
        data_id: NonNegativeInt,
        update: OBDDataUpdate,
        case: Case = Depends(case_from_workshop)
):
    """Update a specific obd dataset from a case."""
    obd_data = await case.update_obd_data(data_id=data_id, update=update)
    if obd_data is not None:
        return obd_data
    else:
        exception_detail = f"No obd_data with data_id `{data_id}` in " \
                           f"case '{case.id}'. Available data_ids are " \
                           f"{case.available_obd_data}."
        raise HTTPException(status_code=404, detail=exception_detail)


@router.delete(
    "/{workshop_id}/cases/{case_id}/obd_data/{data_id}",
    status_code=200,
    response_model=Case, tags=["Workshop - Data Management"]
)
async def delete_obd_data(
        data_id: NonNegativeInt, case: Case = Depends(case_from_workshop)
) -> Case:
    """Delete a specific obd dataset from a case."""
    await case.delete_obd_data(data_id)
    return case


@router.get(
    "/{workshop_id}/cases/{case_id}/symptoms",
    status_code=200,
    response_model=List[Symptom], tags=["Workshop - Data Management"]
)
async def list_symptoms(
        case: Case = Depends(case_from_workshop)
) -> List[Symptom]:
    """List all available symptoms for a case."""
    return case.symptoms


@router.post(
    "/{workshop_id}/cases/{case_id}/symptoms",
    status_code=201,
    response_model=Case, tags=["Workshop - Data Management"]
)
async def add_symptom(
        symptom: NewSymptom, case: Case = Depends(case_from_workshop)
) -> Case:
    """Add a new symptom to a case."""
    case = await case.add_symptom(symptom)
    return case


@router.get(
    "/{workshop_id}/cases/{case_id}/symptoms/{data_id}",
    status_code=200,
    response_model=Symptom, tags=["Workshop - Data Management"]
)
async def get_symptom(
        data_id: NonNegativeInt, case: Case = Depends(case_from_workshop)
) -> Symptom:
    """Get a specific symptom from a case."""
    symptom = case.get_symptom(data_id)
    if symptom is not None:
        return symptom
    else:
        exception_detail = f"No symptom with data_id `{data_id}` in " \
                           f"case '{case.id}'. Available data_ids are " \
                           f"{case.available_symptoms}."
        raise HTTPException(status_code=404, detail=exception_detail)


@router.put(
    "/{workshop_id}/cases/{case_id}/symptoms/{data_id}",
    status_code=200,
    response_model=Symptom, tags=["Workshop - Data Management"]
)
async def update_symptom(
        data_id: NonNegativeInt,
        update: SymptomUpdate,
        case: Case = Depends(case_from_workshop)
):
    """Update a specific symptom of a case."""
    symptom = await case.update_symptom(data_id=data_id, update=update)
    if symptom is not None:
        return symptom
    else:
        exception_detail = f"No symptom with data_id `{data_id}` in " \
                           f"case '{case.id}'. Available data_ids are " \
                           f"{case.available_symptoms}."
        raise HTTPException(status_code=404, detail=exception_detail)


@router.delete(
    "/{workshop_id}/cases/{case_id}/symptoms/{data_id}",
    status_code=200,
    response_model=Case, tags=["Workshop - Data Management"]
)
async def delete_symptom(
        data_id: NonNegativeInt, case: Case = Depends(case_from_workshop)
) -> Case:
    """Delete a specific symptom from a case."""
    await case.delete_symptom(data_id)
    return case


@router.get(
    "/{workshop_id}/cases/{case_id}/diag",
    status_code=200,
    response_model=Union[Diagnosis, None],
    tags=["Workshop - Diagnostics"]
)
async def get_diagnosis(case: Case = Depends(case_from_workshop)):
    """Get diagnosis data for this case."""
    if case.diagnosis_id is None:
        return None
    diag = await Diagnosis.get(case.diagnosis_id)
    return diag


@router.post(
    "/{workshop_id}/cases/{case_id}/diag",
    status_code=201,
    response_model=Diagnosis,
    tags=["Workshop - Diagnostics"]
)
async def start_diagnosis(
        case: Case = Depends(case_from_workshop),
        manage_diagnostic_task: DiagnosticTaskManager = Depends(
            DiagnosticTaskManager
        )
):
    """Initialize the diagnosis process for this case."""
    if case.diagnosis_id is not None:
        # Diagnosis for this case was already initialized and is returned as is
        diag = await Diagnosis.get(case.diagnosis_id)
    else:
        # New diagnosis is initialized
        diag = Diagnosis(
            case_id=case.id,
            status="scheduled"
        )
        await diag.create()
        case.diagnosis_id = diag.id
        await case.save()

        # New diagnosis is handed over to diagnostic backend
        await manage_diagnostic_task(case.diagnosis_id)

    return diag


@router.delete(
    "/{workshop_id}/cases/{case_id}/diag",
    status_code=200,
    response_model=None,
    tags=["Workshop - Diagnostics"]
)
async def delete_diagnosis(case: Case = Depends(case_from_workshop)):
    """Stop the diagnosis process for this case."""
    diag = await Diagnosis.get(case.diagnosis_id)
    await diag.delete()
    case.diagnosis_id = None
    await case.save()
    return None


@router.get(
    "/{workshop_id}/cases/{case_id}/diag/attachments/{attachment_id}",
    status_code=200,
    response_class=Response,
    tags=["Workshop - Diagnostics"]
)
async def get_diagnosis_attachment(
        attachment_id: str,
        case: Case = Depends(case_from_workshop),
        attachment_bucket: motor_asyncio.AsyncIOMotorGridFSBucket = Depends(
            AttachmentBucket.create
        )
):
    """Retrieve a specific diagnosis attachment."""
    attachment = await attachment_bucket.open_download_stream(
        ObjectId(attachment_id)
    )
    content = await attachment.read()
    return Response(content=content, media_type="image/png")


@router.get(
    "/{workshop_id}/diagnoses",
    status_code=200,
    response_model=List[Diagnosis],
    tags=["Workshop - Diagnostics"]
)
async def list_diagnoses(
        workshop_id: str, status: Optional[DiagnosisStatus] = None
):
    """List all diagnoses of a workshop, optionally filtered by status."""
    diagnoses = await Diagnosis.find_in_hub(
        workshop_id=workshop_id, status=status
    )
    return diagnoses
