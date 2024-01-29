from enum import Enum
from typing import ClassVar

from beanie import Document


class AnonymousCustomerId(str, Enum):
    unknown = "unknown"
    anonymous = "anonymous"


class Customer(Document):

    class Settings:
        name = "customers"

    # As this is a research project, only allow anonymous customers to avoid
    # accidental storage of personal information
    id: AnonymousCustomerId

    # An unknown id is needed to allow indexing cases by customer
    unknown_id: ClassVar[str] = AnonymousCustomerId.unknown.value
