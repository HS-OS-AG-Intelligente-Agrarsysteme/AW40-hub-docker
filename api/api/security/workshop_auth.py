from fastapi import Depends, HTTPException, status, Path
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import jwt, JWTError
from pydantic import BaseModel, Field, root_validator


from .keycloak import Keycloak

REQUIRED_WORKSHOP_ROLE = "workshop"


failed_auth_exception = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Could not validate token.",
    headers={"WWW-Authenticate": "Bearer"},
)


class WorkshopTokenData(BaseModel):
    """Parses data from a decoded JWT payload."""
    workshop_id: str = Field(alias="preferred_username")
    roles: list[str]

    @root_validator(pre=True)
    @classmethod
    def parse_roles_from_keycloak_token(cls, values):
        values["roles"] = values.get("realm_access", {}).get("roles", [])
        return values


async def require_token(
        credentials: HTTPAuthorizationCredentials = Depends(
            HTTPBearer(bearerFormat="JWT")
        )
):
    """Require an authorization header with value 'Bearer <JWT>'."""
    return credentials.credentials


async def verify_workshop_token(
        token: str = Depends(require_token),
        jwt_pub_key: str = Depends(Keycloak.get_public_key_for_workshop_realm)
) -> WorkshopTokenData:
    """Decode and verify a JWT and parse data from payload."""
    try:
        payload = jwt.decode(token, jwt_pub_key, options={"verify_aud": False})
        return WorkshopTokenData(**payload)
    except JWTError:
        raise failed_auth_exception


async def authorized_workshop_id(
        workshop_id: str = Path(...),
        token_data: WorkshopTokenData = Depends(verify_workshop_token)
) -> str:
    """
    Authorize access to a workshop_id if it matches the Id in a token and
    is assigned a role that indicates that the user account is indeed a
    workshop account.
    """
    if workshop_id != token_data.workshop_id:
        raise failed_auth_exception
    if REQUIRED_WORKSHOP_ROLE not in token_data.roles:
        raise failed_auth_exception
    else:
        return workshop_id