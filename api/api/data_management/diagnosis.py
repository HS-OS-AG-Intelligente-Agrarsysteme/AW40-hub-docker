from datetime import datetime
from enum import Enum
from typing import List, Optional

from beanie import Document, Indexed, PydanticObjectId, before_event, Delete
from motor import motor_asyncio
from pydantic import BaseModel, Field
from pymongo import IndexModel


class Action(Document):
    """Describes an action, that can be required of an user"""

    class Settings:
        name = "actions"

    id: str
    instruction: str

    action_type: str = None
    data_type: str = None
    component: str = None


class ToDo(Document):
    """Maps diagnosis to their (currently) required actions."""

    timestamp: datetime = Field(default_factory=datetime.utcnow)

    action_id: Indexed(str)
    diagnosis_id: Indexed(PydanticObjectId)

    class Settings:
        name = "todos"
        indexes = [
            IndexModel(
                [("diagnosis_id", 1), ("action_id", 1)],
                name="diagnosis_action_index_ASCENDING",
                unique=True
            ),
        ]


class DiagnosisStatus(str, Enum):
    scheduled = "scheduled"
    action_required = "action_required"
    processing = "processing"
    finished = "finished"


class DiagnosisLogEntry(BaseModel):
    message: str
    attachment: Optional[PydanticObjectId] = None


class AttachmentBucket:
    bucket: motor_asyncio.AsyncIOMotorGridFSBucket = None

    @classmethod
    def create(cls):
        """
        Factory to use in endpoints handlers to create gridfs bucket
        to store attachments
        """
        if cls.bucket is None:
            raise AttributeError("No bucket configured to store attachments")
        return cls.bucket


class DiagnosisBase(BaseModel):
    """Diagnosis Meta Data"""
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    status: DiagnosisStatus = None
    state_machine_log: List[DiagnosisLogEntry] = []
    case_id: PydanticObjectId


class DiagnosisDB(DiagnosisBase, Document):
    """Internal Diagnosis Representation"""

    class Settings:
        name = "diagnosis"

    case_id: Indexed(PydanticObjectId, unique=True)

    @before_event(Delete)
    async def _delete_todos(self):
        """Make sure any todos associated with this diagnosis are removed"""
        await ToDo.find(ToDo.diagnosis_id == self.id).delete()

    async def to_diagnosis(self):
        """
        Convert this internal representation to the external Diagnosis
        representation for serving via the API.
        """

        # Get all todos currently associated with this diagnosis and fetch the
        # respective actions
        todos = await ToDo.find_many({"diagnosis_id": self.id}).to_list()
        action_ids = [todo.action_id for todo in todos]
        todo_actions = await Action.find_many(
            {"_id": {"$in": action_ids}}
        ).to_list()

        # The external representation will include all meta data stored in the
        # internal representation plus the currently required actions
        diag = Diagnosis(
            todos=todo_actions,
            **self.dict()
        )
        return diag


class Diagnosis(DiagnosisBase, allow_population_by_field_name=True):
    """Represents the current state of a diagnosis."""

    # Includes list of actions required by user
    todos: List[Action] = []

    # id field is needed for easy convertability from internal DiagnosisDB
    id: PydanticObjectId = Field(alias="_id")
