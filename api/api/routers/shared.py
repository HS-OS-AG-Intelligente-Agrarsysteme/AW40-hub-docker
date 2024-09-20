from typing import (
    List,
    Literal,
    Callable,
    Optional
)

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import APIRouter, HTTPException, Depends
from pydantic import NonNegativeInt

from ..data_management import (
    Case, Customer, Vehicle, TimeseriesData, OBDData, Symptom
)
from ..security.token_auth import authorized_shared_access

tags_metadata = [
    {
        "name": "Shared",
        "description": "Read access to shared ressources"
    }
]


router = APIRouter(
    tags=["Shared"],
    dependencies=[Depends(authorized_shared_access)]
)


@router.get("/cases", status_code=200, response_model=List[Case])
async def list_cases(
        customer_id: Optional[str] = None,
        vin: Optional[str] = None,
        workshop_id: Optional[str] = None
) -> List[Case]:
    """
    List all cases in Hub. Query params can be used to filter by `customer_id`,
    `vin` and `workshop_id`.
    """
    cases = await Case.find_in_hub(
        customer_id=customer_id, vin=vin, workshop_id=workshop_id
    )
    return cases


async def case_by_id(case_id: str) -> Case:
    """
    Fetch a case from the database or throw 404 if the passed id is invalid.
    """
    no_case_exception = HTTPException(
        status_code=404, detail=f"No case with id `{case_id}`."
    )
    try:
        document_id = ObjectId(case_id)
    except InvalidId:
        # invalid id reports not found to user
        raise no_case_exception

    case = await Case.get(document_id)
    if case is not None:
        return case
    else:
        raise no_case_exception


@router.get("/cases/{case_id}", status_code=200, response_model=Case)
async def get_case(case: Case = Depends(case_by_id)) -> Case:
    """Get a specific case by id."""
    return case


@router.get(
    "/cases/{case_id}/timeseries_data",
    status_code=200,
    response_model=List[TimeseriesData]
)
def list_timeseries_data(
        case: Case = Depends(case_by_id)
) -> List[TimeseriesData]:
    """List all available timeseries datasets for a case."""
    return case.timeseries_data


class DatasetById:
    """
    Parameterized dependency to fetch a dataset by id or raise 404 if the
    data_id is not existent.
    """
    def __init__(
            self, data_type: Literal["timeseries_data", "obd_data", "symptom"]
    ):
        self.data_type = data_type

    def __call__(
            self, data_id: NonNegativeInt, case: Case = Depends(case_by_id)
    ):
        # Depending on the configured data_type, another db access function
        # from case is used
        get_func = getattr(case, f"get_{self.data_type}")
        dataset = get_func(data_id)
        if dataset is not None:
            return dataset
        else:
            exception_detail = f"No {self.data_type} with data_id " \
                               f"`{data_id}` in case {case.id}."
            raise HTTPException(status_code=404, detail=exception_detail)


# Endpoint dependency to fetch timeseries_data by data_id
timeseries_data_by_id: Callable[
    [NonNegativeInt, Case], TimeseriesData
] = DatasetById("timeseries_data")


@router.get(
    "/cases/{case_id}/timeseries_data/{data_id}",
    status_code=200,
    response_model=TimeseriesData
)
async def get_timeseries_data(
        timeseries_data: TimeseriesData = Depends(timeseries_data_by_id)
) -> TimeseriesData:
    """Get a specific timeseries dataset from a case."""
    return timeseries_data


@router.get(
    "/cases/{case_id}/timeseries_data/{data_id}/signal",
    status_code=200,
    response_model=List[float]
)
async def get_timeseries_data_signal(
        timeseries_data: TimeseriesData = Depends(timeseries_data_by_id)
) -> List[float]:
    """Get the signal of a specific timeseries dataset from a case."""
    return await timeseries_data.get_signal()


@router.get(
    "/cases/{case_id}/obd_data",
    status_code=200,
    response_model=List[OBDData]
)
async def list_obd_data(
        case: Case = Depends(case_by_id)
) -> List[OBDData]:
    """List all available obd datasets for a case."""
    return case.obd_data


# Endpoint dependency to fetch obd_data by data_id
obd_data_by_id: Callable[
    [NonNegativeInt, Case], OBDData
] = DatasetById("obd_data")


@router.get(
    "/cases/{case_id}/obd_data/{data_id}",
    status_code=200,
    response_model=OBDData
)
async def get_obd_data(
        obd_data: OBDData = Depends(obd_data_by_id)
) -> OBDData:
    """Get a specific obd dataset from a case."""
    return obd_data


@router.get(
    "/cases/{case_id}/symptoms",
    status_code=200,
    response_model=List[Symptom]
)
async def list_symptoms(
        case: Case = Depends(case_by_id)
) -> List[Symptom]:
    """List all available symptoms for a case."""
    return case.symptoms


# Endpoint dependency to fetch symptom by data_id
symptom_by_id: Callable[
    [NonNegativeInt, Case], Symptom
] = DatasetById("symptom")


@router.get(
    "/cases/{case_id}/symptoms/{data_id}",
    status_code=200,
    response_model=Symptom
)
async def get_symptom(
        symptom: Symptom = Depends(symptom_by_id)
) -> Symptom:
    """Get a specific symptom from a case."""
    return symptom


@router.get("/customers", status_code=200, response_model=List[Customer])
async def list_customers() -> List[Customer]:
    """
    List all customers in Hub.
    """
    customers = await Customer.find_all().to_list()
    return customers


@router.get(
    "/customers/{customer_id}", status_code=200, response_model=Customer
)
async def get_customer(customer_id: str) -> Customer:
    customer = await Customer.get(customer_id)
    if customer is not None:
        return customer
    else:
        exception_detail = f"No customer with id `{customer_id}`"
        raise HTTPException(status_code=404, detail=exception_detail)


@router.get("/vehicles", status_code=200, response_model=List[Vehicle])
async def list_vehicles() -> List[Vehicle]:
    """
    List all vehicles in Hub.
    """
    vehicles = await Vehicle.find_all().to_list()
    return vehicles


@router.get("/vehicles/{vin}", status_code=200, response_model=Vehicle)
async def get_vehicle(vin: str) -> Vehicle:
    vehicle = await Vehicle.find_one({"vin": vin})
    if vehicle is not None:
        return vehicle
    else:
        exception_detail = f"No vehicle with vin `{vin}`"
        raise HTTPException(status_code=404, detail=exception_detail)
