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

    first_name: str
    last_name: str
    phone: Optional[str] = None
    email: Optional[str] = None
    postcode: Optional[str] = None
    city: Optional[str] = None
    street: Optional[str] = None
    house_number: Optional[str] = None


class Customer(CustomerBase, Document):
    timestamp: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "customers"
