import pytest

from bson import ObjectId
from pymongo.errors import DuplicateKeyError

from api.data_management.diagnosis import (
    Action,
    ToDo,
    DiagnosisDB
)


@pytest.fixture
def case_id():
    return str(ObjectId())


@pytest.mark.asyncio
async def test_automatic_todo_deletion(case_id, initialized_beanie_context):
    async with initialized_beanie_context:
        # add new diagnosis to
        diag_db = DiagnosisDB(case_id=case_id)
        await diag_db.save()

        # add a action to the db
        action = Action(id="test-action", instruction="We are testing!")
        await action.save()

        # associate diagnosis and action by creating a todos entry in the db
        todo = ToDo(action_id=action.id, diagnosis_id=diag_db.id)
        await todo.save()

        # delete the diagnosis and confirm that associated todos are deleted
        await diag_db.delete()
        todo_db = await ToDo.find_one({"diagnosis_id": diag_db.id})
        assert todo_db is None


@pytest.mark.asyncio
async def test_to_diagnosis_without_todos(case_id, initialized_beanie_context):
    async with initialized_beanie_context:
        # seed db with new diagnosis
        diag_db = DiagnosisDB(case_id=case_id)
        await diag_db.save()
        # convert to api representation
        diag = await diag_db.to_diagnosis()
        assert diag.todos == []


@pytest.mark.asyncio
async def test_to_diagnosis_with_todos(case_id, initialized_beanie_context):
    async with initialized_beanie_context:
        # add new diagnosis to
        diag_db = DiagnosisDB(case_id=case_id)
        await diag_db.save()

        # add a action to the db
        action = Action(id="test-action", instruction="We are testing!")
        await action.save()

        # associate diagnosis and action by creating a todos entry in the db
        todo = ToDo(action_id=action.id, diagnosis_id=diag_db.id)
        await todo.save()

        # confirm that entries in todos collection are resolved when converting
        # to api representation
        diag = await diag_db.to_diagnosis()
        assert diag.todos == [action]


@pytest.mark.asyncio
async def test_todos_are_indexed(initialized_beanie_context):
    async with initialized_beanie_context:
        todo = ToDo(diagnosis_id=ObjectId(), action_id="aid")
        await todo.save()
        todo_2 = ToDo(diagnosis_id=todo.diagnosis_id, action_id=todo.action_id)
        # no duplication of a diagnosis - action pair in todos allowed
        with pytest.raises(DuplicateKeyError):
            await todo_2.save()
