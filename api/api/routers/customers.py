from typing import List

from bson import ObjectId
from bson.errors import InvalidId

from fastapi import APIRouter, Depends, HTTPException

from ..data_management import (
    Customer, CustomerBase
)
from ..security.token_auth import authorized_customers_access

tags_metadata = [
    {
        "name": "Customers",
        "description": "Customer data management"
    }
]

router = APIRouter(
    tags=["Customers"],
    dependencies=[Depends(authorized_customers_access)]
)


@router.get("/customers", status_code=200, response_model=List[Customer])
async def list_customers():
    """Retrieve list of customers."""
    customers = await Customer.find().to_list()
    return customers


@router.post("/customers", status_code=201, response_model=Customer)
async def add_customer(customer: CustomerBase):
    """Add a new customer."""
    customer = await Customer(**customer.dict()).create()
    return customer


async def customer_by_id(customer_id: str) -> Customer:
    """
    Reusable dependency to handle retrieval of customer by ID. 404 HTTP
    exception is raised in case of invalid id.
    """
    no_customer_with_id_exception = HTTPException(
        status_code=404, detail=f"No customer with id '{customer_id}' found."
    )
    # Invalid ID format causes 404
    try:
        customer_id = ObjectId(customer_id)
    except InvalidId:
        raise no_customer_with_id_exception
    # Non-existing ID causes 404
    customer = await Customer.get(customer_id)
    if customer is None:
        raise no_customer_with_id_exception

    return customer


@router.get(
    "/customers/{customer_id}",
    status_code=200,
    response_model=Customer
)
async def get_customer(customer: Customer = Depends(customer_by_id)):
    """Get a specific customer by id."""
    return customer


@router.patch(
    "/customers/{customer_id}",
    status_code=200,
    response_model=Customer
)
async def update_customer(
        update: CustomerBase, customer: Customer = Depends(customer_by_id)
):
    """Update a specific customer."""
    await customer.set(update.dict(exclude_unset=True))
    return customer


@router.delete(
    "/customers/{customer_id}",
    status_code=200,
    response_model=None
)
async def delete_customer(customer: Customer = Depends(customer_by_id)):
    """Delete a specific customer."""
    await customer.delete()
