from typing import List

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import APIRouter, Depends, HTTPException, Response, Request, Query

from .utils import pagination
from ..data_management import (
    Customer, CustomerBase, CustomerUpdate
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


@router.get("/", status_code=200, response_model=List[Customer])
async def list_customers(
        response: Response,
        request: Request,
        page: int = Query(default=0, ge=0),
        page_size: int = Query(default=30, ge=1, le=30)
):
    """
    Retrieve list of customers.

    Pagination:
    Pages are zero-index and page size can be varied between 1 and 30.
    To aid navigation of pages, response headers will contain the `link` field
    as specified in [RFC5988](https://datatracker.ietf.org/doc/html/rfc5988#section-5)
    and as used by the [GitHub API](https://docs.github.com/en/rest/using-the-rest-api/using-pagination-in-the-rest-api?apiVersion=2022-11-28).
    It will contain URLs for the first and last available page as well as the
    next and and previous page. Next and previous are only included if they
    exist, that is, if the requested page is not the first or last page,
    respectively.
    """  # noqa: E501
    # Raise 400 Bas Request for out-of-range request with non-zero page index
    customer_count = await Customer.count()
    last_page = pagination.last_page_index(
        page_size=page_size, document_count=customer_count
    )
    if page > last_page:
        raise HTTPException(
            status_code=400,
            detail=f"Valid pages for the selected page_size={page_size} are "
                   f"0, ..., {last_page}."
        )
    # Fetch requested chunk of customers in alphabetic order
    customers = await Customer \
        .find() \
        .sort(Customer.last_name, Customer.first_name) \
        .skip(page * page_size) \
        .limit(page_size) \
        .to_list()
    # Set link headers to aid with pagination
    response.headers["link"] = pagination.link_header(
        page=page,
        page_size=page_size,
        document_count=customer_count,
        url=str(request.url)
    )
    return customers


@router.post("/", status_code=201, response_model=Customer)
async def add_customer(customer: CustomerBase):
    """Add a new customer."""
    customer = await Customer(**customer.dict()).create()
    return customer


async def customer_by_id(customer_id: str) -> Customer:
    """
    Reusable dependency to handle retrieval of customer by ID. 404 HTTP
    exception is raised in case of invalid id.
    """
    # Invalid ID format causes 404
    try:
        customer_id = ObjectId(customer_id)
    except InvalidId:
        raise HTTPException(
            status_code=404, detail="Invalid format for customer_id."
        )
    # Non-existing ID causes 404
    customer = await Customer.get(customer_id)
    if customer is None:
        raise HTTPException(
            status_code=404,
            detail=f"No customer with id '{customer_id}' found."
        )

    return customer


@router.get(
    "/{customer_id}",
    status_code=200,
    response_model=Customer
)
async def get_customer(customer: Customer = Depends(customer_by_id)):
    """Get a specific customer by id."""
    return customer


@router.patch(
    "/{customer_id}",
    status_code=200,
    response_model=Customer
)
async def update_customer(
        update: CustomerUpdate, customer: Customer = Depends(customer_by_id)
):
    """Update a specific customer."""
    await customer.set(update.dict(exclude_unset=True))
    return customer


@router.delete(
    "/{customer_id}",
    status_code=200,
    response_model=None
)
async def delete_customer(customer: Customer = Depends(customer_by_id)):
    """Delete a specific customer."""
    await customer.delete()
