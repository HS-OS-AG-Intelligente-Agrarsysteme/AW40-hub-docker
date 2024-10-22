from fastapi import Depends, HTTPException, status, Path
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import jwt, JWTError
from pydantic import BaseModel, Field, model_validator


from .keycloak import Keycloak

# required role to access workshop specific resources
REQUIRED_WORKSHOP_ROLE = "workshop"
# required role to access shared resources
REQUIRED_SHARED_ROLE = "shared"
# required role for customer data management
REQUIRED_CUSTOMERS_ROLE = "customers"


failed_auth_exception = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Could not validate token.",
    headers={"WWW-Authenticate": "Bearer"},
)


class TokenData(BaseModel):
    """Parses data from a decoded JWT payload."""
    username: str = Field(alias="preferred_username")
    roles: list[str]

    @model_validator(mode="before")
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


async def verify_token(
        token: str = Depends(require_token),
        jwt_pub_key: str = Depends(Keycloak.get_public_key_for_workshop_realm)
) -> TokenData:
    """Decode and verify a JWT and parse data from payload."""
    try:
        payload = jwt.decode(token, jwt_pub_key, options={"verify_aud": False})
        return TokenData(**payload)
    except JWTError:
        raise failed_auth_exception


async def authorized_workshop_id(
        workshop_id: str = Path(...),
        token_data: TokenData = Depends(verify_token)
) -> str:
    """
    Authorize access to a workshop_id if it matches the username in a token and
    is assigned a role that indicates that the user account is indeed a
    workshop account.
    """
    if workshop_id != token_data.username:
        raise failed_auth_exception
    if REQUIRED_WORKSHOP_ROLE not in token_data.roles:
        raise failed_auth_exception
    else:
        return workshop_id


async def authorized_shared_access(
        token_data: TokenData = Depends(verify_token)
) -> None:
    """
    Authorize access to shared resources if the user is assigned the respective
    role.
    """
    if REQUIRED_SHARED_ROLE not in token_data.roles:
        raise failed_auth_exception


async def authorized_knowledge_access(
        token_data: TokenData = Depends(verify_token)
) -> None:
    """
    Authorized access to knowledge resources if the user is assigned a workshop
    role or a shared role.
    """
    required_roles = set({REQUIRED_SHARED_ROLE, REQUIRED_WORKSHOP_ROLE})
    assigned_roles = set(token_data.roles)
    if not required_roles.intersection(assigned_roles):
        raise failed_auth_exception


async def authorized_customers_access(
        token_data: TokenData = Depends(verify_token)
):
    """
    Authorize access to customer data management if the user is assigned the
    respective role.
    """
    if REQUIRED_CUSTOMERS_ROLE not in token_data.roles:
        raise failed_auth_exception
