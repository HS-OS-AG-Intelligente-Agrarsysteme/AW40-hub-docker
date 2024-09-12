from datetime import datetime
from typing import Optional

import pymongo
from beanie import Document, after_event, Delete
from pydantic import BaseModel, Field

from .case import Case


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


class CustomerUpdate(CustomerBase):
    first_name: Optional[str] = None
    last_name: Optional[str] = None


class Customer(CustomerBase, Document):
    timestamp: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "customers"
        indexes = [
            [
                ("last_name", pymongo.ASCENDING),
                ("first_name", pymongo.ASCENDING),
            ]
        ]

    @after_event(Delete)
    async def _remove_id_from_cases(self):
        """
        Remove the customer_id foreign key from each case that points to the
        deleted customer.
        """
        cases = await Case.find_in_hub(customer_id=self.id)
        for case in cases:
            await case.set({Case.customer_id: None})
