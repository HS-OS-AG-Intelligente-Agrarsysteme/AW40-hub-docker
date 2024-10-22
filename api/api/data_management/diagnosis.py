from datetime import datetime, UTC
from enum import Enum
from typing import List, Optional
from typing_extensions import Annotated

from beanie import Document, Indexed, PydanticObjectId
from motor import motor_asyncio
from pydantic import BaseModel, Field


class Action(BaseModel):
    """Describes an action, that can be required of an user"""

    id: Optional[str] = None
    instruction: str

    action_type: Optional[str] = None
    data_type: Optional[str] = None
    component: Optional[str] = None


class DiagnosisStatus(str, Enum):
    scheduled = "scheduled"
    action_required = "action_required"
    processing = "processing"
    finished = "finished"
    failed = "failed"


class DiagnosisLogEntry(BaseModel):
    message: str
    attachment: Optional[PydanticObjectId] = None


class AttachmentBucket:
    bucket: Optional[motor_asyncio.AsyncIOMotorGridFSBucket] = None

    @classmethod
    def create(cls):
        """
        Factory to use in endpoints handlers to create gridfs bucket
        to store attachments
        """
        if cls.bucket is None:
            raise AttributeError("No bucket configured to store attachments")
        return cls.bucket


class Diagnosis(Document):
    """Internal Diagnosis Representation"""

    class Settings:
        name = "diagnosis"

    timestamp: datetime = Field(default_factory=lambda: datetime.now(UTC))
    status: Optional[DiagnosisStatus] = None
    state_machine_log: List[DiagnosisLogEntry] = []
    case_id: Annotated[PydanticObjectId, Indexed(unique=True)]
    todos: List[Action] = []

    @classmethod
    async def find_in_hub(
            cls,
            workshop_id: Optional[str] = None,
            status: Optional[DiagnosisStatus] = None
    ) -> List["Diagnosis"]:
        """
        Get list of all diagnoses of a workshop, optionally filtered by status.
        """
        pipeline = [
            # Lookup case in cases collection restricted to workshop
            {
                "$lookup": {
                    "from": "cases",
                    "localField": "case_id",
                    "foreignField": "_id",
                    "as": "case",
                    "pipeline": [
                        {"$match": {"workshop_id": workshop_id}},
                        {"$project": {"_id": 1}}
                    ]
                }
            },
            # Indicate if a diagnosis has a matching case
            {
                "$addFields": {
                    "case_found": {
                        "$size": "$case"
                    }
                }
            },
            # Only keep diagnoses with matching case
            {
                "$match": {
                    "case_found": 1
                }
            },
            # Remove leftovers from lookup to recover plain diagnosis schema
            {
                "$project": {
                    "case": 0,
                    "case_found": 0
                }
            }
        ]

        if status is not None:
            # Only keep results with specified status
            pipeline.append({"$match": {"status": status}})

        return await cls.aggregate(
            pipeline, projection_model=Diagnosis
        ).to_list()
