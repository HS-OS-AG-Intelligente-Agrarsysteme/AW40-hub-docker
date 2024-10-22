from datetime import datetime, UTC
from enum import Enum
from typing import Optional

from pydantic import (
    BaseModel,
    Field,
    NonNegativeInt,
    ConfigDict
)


class SymptomLabel(str, Enum):
    unknown = "unknown"
    ok = "ok"
    defect = "defect"


class NewSymptom(BaseModel):
    """Schema for a new symptom added via the api."""
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "component": "battery",
                "label": "defect"
            }
        }
    )

    timestamp: datetime = Field(default_factory=lambda: datetime.now(UTC))
    component: str
    label: SymptomLabel


class Symptom(NewSymptom):
    """Schema for existing symptom."""
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "timestamp": "2023-04-04T07:15:22.887633",
                "component": "battery",
                "label": "defect",
                "data_id": 0
            }
        }
    )

    data_id: Optional[NonNegativeInt] = None


class SymptomUpdate(BaseModel):
    """Schema to update a symptom."""

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "label": "defect"
            }
        }
    )

    timestamp: Optional[datetime] = None
    component: Optional[str] = None
    label: Optional[SymptomLabel] = None
