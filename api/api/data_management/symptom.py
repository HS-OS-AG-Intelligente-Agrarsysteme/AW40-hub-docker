from datetime import datetime
from enum import Enum

from pydantic import BaseModel, Field, NonNegativeInt

from .vehicle import Component


class SymptomLabel(str, Enum):
    unknown = "unknown"
    ok = "ok"
    defect = "defect"


class NewSymptom(BaseModel):
    """Schema for a new symptom added via the api."""
    class Config:
        schema_extra = {
            "example": {
                "component": "battery",
                "label": "defect"
            }
        }

    timestamp: datetime = Field(default_factory=datetime.utcnow)
    component: Component
    label: SymptomLabel


class Symptom(NewSymptom):
    """Schema for existing symptom."""
    class Config:
        schema_extra = {
            "example": {
                "timestamp": "2023-04-04T07:15:22.887633",
                "component": "battery",
                "label": "defect",
                "data_id": 0
            }
        }

    data_id: NonNegativeInt = None


class SymptomUpdate(BaseModel):
    """Schema to update a symptom."""

    class Config:
        schema_extra = {
            "example": {
                "label": "defect"
            }
        }

    timestamp: datetime = None
    component: Component = None
    label: SymptomLabel = None
