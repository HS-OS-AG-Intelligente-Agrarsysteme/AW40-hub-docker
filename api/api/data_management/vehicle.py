from enum import Enum
from typing_extensions import Annotated, Optional

from beanie import Document, Indexed
from pydantic import BaseModel


class Component(str, Enum):
    """All the components that a vehicle can have."""
    battery = "battery"
    maf_sensor = "maf_sensor"
    lambda_sensor_before_cat = "lambda_sensor_before_cat"
    lambda_sensor_behind_cat = "lambda_sensor_behind_cat"
    boost_pressure_solenoid_valve = "boost_pressure_solenoid_valve"
    boost_pressure_control_valve = "boost_pressure_control_valve"
    tc_boost_control_position_sensor = "tc_boost_control_position_sensor"
    engine_control_unit = "engine_control_unit"
    variable_nozzle_tc = "variable_nozzle_tc"


class Vehicle(Document):

    # class Config:
    # 'vin' is used instead of 'id'
    #    fields = {"id": {"exclude": True}} # Deprecated

    class Settings:
        name = "vehicles"

    vin: Annotated[str, Indexed(str, unique=True)]
    tsn: Optional[str] = None
    year_build: Optional[int] = None


class VehicleUpdate(BaseModel):
    tsn: Optional[str] = None
    year_build: Optional[int] = None
