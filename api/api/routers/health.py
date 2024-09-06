from fastapi import APIRouter

tags_metadata = [
    {
        "name": "Health",
        "description": "Endpoints for health checks"
    }
]

router = APIRouter(tags=["Health"])


@router.get("/ping", status_code=200)
def ping():
    return {"msg": "ok"}
