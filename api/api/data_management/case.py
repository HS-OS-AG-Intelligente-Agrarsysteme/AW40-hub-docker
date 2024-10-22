from datetime import datetime, UTC
from enum import Enum
from typing import (
    Annotated,
    List,
    Optional,
    Tuple,
    Any,
    Self
)

from beanie import (
    Document,
    Indexed,
    before_event,
    Insert,
    Delete,
    PydanticObjectId
)
from pydantic import (
    BaseModel,
    Field,
    NonNegativeInt,
    ConfigDict
)

from .diagnosis import Diagnosis
from .obd_data import NewOBDData, OBDData, OBDDataUpdate
from .symptom import NewSymptom, Symptom, SymptomUpdate
from .timeseries_data import (
    NewTimeseriesData, TimeseriesData, TimeseriesDataUpdate
)
from .vehicle import Vehicle


class Occasion(str, Enum):
    unknown = "unknown"
    service_routine = "service_routine"
    problem_defect = "problem_defect"


class Status(str, Enum):
    open = "open"
    closed = "closed"


class NewCase(BaseModel):
    """Schema for new cases added via the api."""

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "vehicle_vin": "VIN42",
                "occasion": Occasion.service_routine,
                "milage": 42
            }
        }
    )

    vehicle_vin: str
    customer_id: Optional[PydanticObjectId] = None
    occasion: Occasion = Occasion.unknown
    milage: Optional[int] = None


class CaseUpdate(BaseModel):
    """Metadata of a case that can be updated after creation."""
    timestamp: Optional[datetime] = None
    occasion: Optional[Occasion] = None
    milage: Optional[int] = None
    status: Optional[Status] = None


class Case(Document):
    """Complete case schema and major db interfacing class."""

    model_config = ConfigDict(
        validate_assignment=True
    )

    class Settings:
        name = "cases"

    # case descriptions
    timestamp: datetime = Field(default_factory=lambda: datetime.now(UTC))
    occasion: Occasion = Occasion.unknown
    milage: Optional[int] = None
    status: Status = Status.open

    # foreign keys
    customer_id: Optional[
        Annotated[PydanticObjectId, Indexed(unique=False)]
    ] = None
    vehicle_vin: Annotated[str, Indexed(unique=False)]
    workshop_id: Annotated[str, Indexed(unique=False)]
    diagnosis_id: Optional[Annotated[PydanticObjectId, Indexed()]] = None

    # diagnostic data
    timeseries_data: List[TimeseriesData] = []
    obd_data: List[OBDData] = []
    symptoms: List[Symptom] = []

    # keep track of diagnostic data added to set appropriate data_ids
    timeseries_data_added: NonNegativeInt = 0
    obd_data_added: NonNegativeInt = 0
    symptoms_added: NonNegativeInt = 0

    schema_version: int = Field(
        default=0,
        exclude=True
    )

    @before_event(Insert)
    async def insert_vehicle(self):
        """
        Create the vehicle if non-existent, e.g. if it is the first case for
        this vehicle.
        """
        vehicle = await Vehicle.find_one({"vin": self.vehicle_vin})
        if vehicle is None:
            vehicle = Vehicle(vin=self.vehicle_vin)
            await vehicle.insert()

    @classmethod
    async def find_in_hub(
            cls,
            customer_id: Optional[str] = None,
            vin: Optional[str] = None,
            workshop_id: Optional[str] = None
    ) -> List[Self]:
        """
        Get list of all cases filtered by customer_id, vehicle_vin and
        workshop_id.
        """
        filter = {}
        if customer_id is not None:
            filter["customer_id"] = PydanticObjectId(customer_id)
        if vin is not None:
            filter["vehicle_vin"] = vin
        if workshop_id is not None:
            filter["workshop_id"] = workshop_id

        cases = await cls.find(filter).to_list()
        return cases

    async def add_timeseries_data(self, new_data: NewTimeseriesData) -> Self:
        # signal data is stored and converted to ref
        timeseries_data = await new_data.to_timeseries_data()
        # append to data array
        timeseries_data.data_id = self.timeseries_data_added
        self.timeseries_data.append(timeseries_data)
        self.timeseries_data_added += 1
        await self.save()
        return self

    async def add_obd_data(self, new_obd_data: NewOBDData) -> Self:
        obd_data = OBDData(data_id=self.obd_data_added,
                           **new_obd_data.model_dump())
        self.obd_data.append(obd_data)
        self.obd_data_added += 1
        await self.save()
        return self

    async def add_symptom(self, new_symptom: NewSymptom) -> Self:
        symptom = Symptom(data_id=self.symptoms_added,
                          **new_symptom.model_dump())
        self.symptoms.append(symptom)
        self.symptoms_added += 1
        await self.save()
        return self

    @staticmethod
    def find_data_in_array(
            data_array: list, data_id: NonNegativeInt
    ) -> Tuple[NonNegativeInt, Any] | Tuple[None, None]:
        for i, d in enumerate(data_array):
            if d.data_id == data_id:
                return i, d

        return None, None

    def get_timeseries_data(
            self, data_id: NonNegativeInt
    ) -> TimeseriesData | None:
        _, timeseries_data = self.find_data_in_array(
            data_array=self.timeseries_data, data_id=data_id
        )
        return timeseries_data

    def get_obd_data(self, data_id: NonNegativeInt) -> OBDData | None:
        _, obd_data = self.find_data_in_array(
            data_array=self.obd_data, data_id=data_id
        )
        return obd_data

    def get_symptom(self, data_id: NonNegativeInt) -> Symptom | None:
        _, symptom = self.find_data_in_array(
            data_array=self.symptoms, data_id=data_id
        )
        return symptom

    async def delete_timeseries_data(self, data_id: NonNegativeInt):
        idx, timeseries_data = self.find_data_in_array(
            data_array=self.timeseries_data, data_id=data_id
        )
        if timeseries_data is not None and idx is not None:
            await timeseries_data.delete_signal()
            self.timeseries_data.pop(idx)
            await self.save()

    async def delete_obd_data(self, data_id: NonNegativeInt):
        idx, _ = self.find_data_in_array(
            data_array=self.obd_data, data_id=data_id
        )
        if idx is not None:
            self.obd_data.pop(idx)
            await self.save()

    async def delete_symptom(self, data_id: NonNegativeInt):
        idx, _ = self.find_data_in_array(
            data_array=self.symptoms, data_id=data_id
        )
        if idx is not None:
            self.symptoms.pop(idx)
            await self.save()

    async def update_timeseries_data(
            self, data_id: NonNegativeInt, update: TimeseriesDataUpdate
    ) -> TimeseriesData | None:
        idx, timeseries_data = self.find_data_in_array(
            data_array=self.timeseries_data, data_id=data_id
        )
        if timeseries_data is not None and idx is not None:
            timeseries_data = timeseries_data.model_dump()
            timeseries_data.update(update.model_dump(exclude_unset=True))
            timeseries_data = TimeseriesData(**timeseries_data)
            self.timeseries_data[idx] = timeseries_data
            await self.save()
        return timeseries_data

    async def update_obd_data(
            self, data_id: NonNegativeInt, update: OBDDataUpdate
    ) -> OBDData | None:
        idx, obd_data = self.find_data_in_array(
            data_array=self.obd_data, data_id=data_id
        )
        if obd_data is not None and idx is not None:
            obd_data = obd_data.model_dump()
            obd_data.update(update.model_dump(exclude_unset=True))
            obd_data = OBDData(**obd_data)
            self.obd_data[idx] = obd_data
            await self.save()
        return obd_data

    async def update_symptom(
            self, data_id: NonNegativeInt, update: SymptomUpdate
    ) -> Symptom | None:
        idx, symptom = self.find_data_in_array(
            data_array=self.symptoms, data_id=data_id
        )
        if symptom is not None and idx is not None:
            symptom = symptom.model_dump()
            symptom.update(update.model_dump(exclude_unset=True))
            symptom = Symptom(**symptom)
            self.symptoms[idx] = symptom
            await self.save()
        return symptom

    @property
    def available_timeseries_data(self):
        return [d.data_id for d in self.timeseries_data]

    @property
    def available_obd_data(self):
        return [d.data_id for d in self.obd_data]

    @property
    def available_symptoms(self):
        return [d.data_id for d in self.symptoms]

    @before_event(Delete)
    async def _delete_all_timeseries_signals(self):
        """
        Make sure that binary signal data stored outside of case is also
        removed.
        """
        for ts in self.timeseries_data:
            if ts is not None:
                await ts.delete_signal()

    @before_event(Delete)
    async def _delete_diagnosis(self):
        """
        Make sure any diagnosis attached to the case is also removed.
        """
        if self.diagnosis_id is not None:
            # delete via instance to make sure Diagnosis event handlers
            # are also executed
            diag = await Diagnosis.get(self.diagnosis_id)
            if diag is not None:
                await diag.delete()
