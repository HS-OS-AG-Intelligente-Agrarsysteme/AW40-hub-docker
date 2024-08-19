from datetime import datetime
from typing import Optional

from beanie import Document
from pydantic import BaseModel, Field


class CustomerBase(BaseModel):

    class Config:
        schema_extra = {
            "example": {
                "first_name": "FirstName",
                "last_name": "LastName"
            }
        }

    first_name: Optional[str]
    last_name: Optional[str]
    address: Optional[str] = None
    contacts: Optional[dict] = None


class Customer(CustomerBase, Document):
    timestamp: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "customers"
