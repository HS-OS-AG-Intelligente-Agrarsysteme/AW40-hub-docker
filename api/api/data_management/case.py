from datetime import datetime
from enum import Enum
from typing import List, Union, Optional

from beanie import (
    Document, Indexed, before_event, Insert, Delete, PydanticObjectId
)
from pydantic import BaseModel, Field, NonNegativeInt

from .customer import Customer
from .diagnosis import DiagnosisDB
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

    class Config:
        schema_extra = {
            "example": {
                "vehicle_vin": "VIN42",
                "customer_id": "firstname.lastname",
                "occasion": Occasion.service_routine,
                "milage": 42
            }
        }

    vehicle_vin: str
    customer_id: Indexed(str, unique=False) = Customer.unknown_id
    occasion: Occasion = Occasion.unknown
    milage: int = None


class CaseUpdate(BaseModel):
    """Metadata of a case that can be updated after creation."""
    timestamp: datetime = None
    occasion: Occasion = None
    milage: int = None
    status: Status = None


class Case(Document):
    """Complete case schema and major db interfacing class."""

    class Config:
        validate_assignment = True
        fields = {"schema_version": {"exclude": True}}

    class Settings:
        name = "cases"

    # case descriptions
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    occasion: Occasion = Occasion.unknown
    milage: int = None
    status: Status = Status.open

    # foreign keys
    customer_id: Indexed(str, unique=False) = Customer.unknown_id
    vehicle_vin: Indexed(str, unique=False)
    workshop_id: Indexed(str, unique=False)
    diagnosis_id: Optional[Indexed(PydanticObjectId)]

    # diagnostic data
    timeseries_data: List[TimeseriesData] = []
    obd_data: List[OBDData] = []
    symptoms: List[Symptom] = []

    # keep track of diagnostic data added to set appropriate data_ids
    timeseries_data_added: NonNegativeInt = 0
    obd_data_added: NonNegativeInt = 0
    symptoms_added: NonNegativeInt = 0

    schema_version: int = 0

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

    @before_event(Insert)
    async def insert_customer(self):
        """
        Create the customer if non-existent, e.g. if it is the first case for
        this customer.
        """
        customer = await Customer.get(self.customer_id)
        if customer is None:
            customer = Customer(id=self.customer_id)
            await customer.insert()

    @classmethod
    async def find_in_hub(
            cls,
            customer_id: str = None,
            vin: str = None,
            workshop_id: str = None
    ):
        """
        Get list of all cases filtered by customer_id, vehicle_vin and
        workshop_id.
        """
        filter = {}
        if customer_id is not None:
            filter["customer_id"] = customer_id
        if vin is not None:
            filter["vehicle_vin"] = vin
        if workshop_id is not None:
            filter["workshop_id"] = workshop_id

        cases = await cls.find(filter).to_list()
        return cases

    async def add_timeseries_data(self, new_data: NewTimeseriesData) -> "Case":
        # signal data is stored and converted to ref
        timeseries_data = await new_data.to_timeseries_data()
        # append to data array
        timeseries_data.data_id = self.timeseries_data_added
        self.timeseries_data.append(timeseries_data)
        self.timeseries_data_added += 1
        await self.save()
        return self

    async def add_obd_data(self, new_obd_data: NewOBDData) -> "Case":
        obd_data = OBDData(data_id=self.obd_data_added, **new_obd_data.dict())
        self.obd_data.append(obd_data)
        self.obd_data_added += 1
        await self.save()
        return self

    async def add_symptom(self, new_symptom: NewSymptom) -> "Case":
        symptom = Symptom(data_id=self.symptoms_added, **new_symptom.dict())
        self.symptoms.append(symptom)
        self.symptoms_added += 1
        await self.save()
        return self

    @staticmethod
    def find_data_in_array(
            data_array: list, data_id: NonNegativeInt
    ) -> (NonNegativeInt, Union[TimeseriesData, OBDData, Symptom]):
        for i, d in enumerate(data_array):
            if d.data_id == data_id:
                return i, d

        return None, None

    def get_timeseries_data(self, data_id: NonNegativeInt) -> TimeseriesData:
        _, timeseries_data = self.find_data_in_array(
            data_array=self.timeseries_data, data_id=data_id
        )
        return timeseries_data

    def get_obd_data(self, data_id: NonNegativeInt) -> OBDData:
        _, obd_data = self.find_data_in_array(
            data_array=self.obd_data, data_id=data_id
        )
        return obd_data

    def get_symptom(self, data_id: NonNegativeInt) -> Symptom:
        _, symptom = self.find_data_in_array(
            data_array=self.symptoms, data_id=data_id
        )
        return symptom

    async def delete_timeseries_data(self, data_id: NonNegativeInt):
        idx, timeseries_data = self.find_data_in_array(
            data_array=self.timeseries_data, data_id=data_id
        )
        if timeseries_data is not None:
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
    ) -> TimeseriesData:
        idx, timeseries_data = self.find_data_in_array(
            data_array=self.timeseries_data, data_id=data_id
        )
        if timeseries_data is not None:
            timeseries_data = timeseries_data.dict()
            timeseries_data.update(update.dict(exclude_unset=True))
            timeseries_data = TimeseriesData(**timeseries_data)
            self.timeseries_data[idx] = timeseries_data
            await self.save()
        return timeseries_data

    async def update_obd_data(
            self, data_id: NonNegativeInt, update: OBDDataUpdate
    ) -> OBDData:
        idx, obd_data = self.find_data_in_array(
            data_array=self.obd_data, data_id=data_id
        )
        if obd_data is not None:
            obd_data = obd_data.dict()
            obd_data.update(update.dict(exclude_unset=True))
            obd_data = OBDData(**obd_data)
            self.obd_data[idx] = obd_data
            await self.save()
        return obd_data

    async def update_symptom(
            self, data_id: NonNegativeInt, update: SymptomUpdate
    ) -> Symptom:
        idx, symptom = self.find_data_in_array(
            data_array=self.symptoms, data_id=data_id
        )
        if symptom is not None:
            symptom = symptom.dict()
            symptom.update(update.dict(exclude_unset=True))
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
            diag = await DiagnosisDB.get(self.diagnosis_id)
            await diag.delete()
