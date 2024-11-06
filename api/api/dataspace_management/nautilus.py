import secrets
from typing import Optional, Tuple
from urllib.parse import urljoin

import httpx

from ..data_management import Asset, Publication, NewPublication


class Nautilus:
    _url: Optional[str] = None
    TIMEOUT: int = 120  # Timeout for external requests to nautilus

    def __init__(self):
        if not self._url:
            raise AttributeError("No Nautilus connection configured.")

    @classmethod
    def configure(cls, url: str):
        """Configure the nautilus connection details."""
        cls._url = url

    @property
    def _publication_url(self):
        return urljoin(self._url, "publish")

    @property
    def _revocation_url(self):
        return urljoin(self._url, "revoke")

    def _post_request(
            self,
            url: str,
            headers: dict,
            json_payload: Optional[dict] = None
    ) -> Tuple[Optional[httpx.Response], str]:
        """
        Helper method to perform a POST request with standard error handling.
        """
        try:
            response = httpx.post(
                url, json=json_payload, headers=headers, timeout=self.TIMEOUT
            )
            response.raise_for_status()
            return response, "success"
        except httpx.TimeoutException:
            return None, "Connection timeout."
        except httpx.HTTPStatusError as e:
            return None, e.response.text

    def publish_access_dataset(
            self,
            asset_url: str,
            asset: "Asset",
            new_publication: NewPublication
    ) -> Tuple[Optional[Publication], str]:
        """
        Publish an asset to Nautilus.
        """
        # Generate a new asset key
        asset_key = secrets.token_urlsafe(32)
        # Set up request payload
        payload = {
            "service_descr": {
                "url": asset_url,
                "api_key": "UNDETERMINED",
                "data_key": asset_key
            },
            "asset_descr": {
                **asset.model_dump(
                    include={"name", "type", "description", "author"}
                ),
                "license": new_publication.license,
                "price": {
                    "value": new_publication.price,
                    "currency": "FIXED_EUROE"
                }
            }
        }
        # Attempt publication
        response, info = self._post_request(
            url=urljoin(self._publication_url, new_publication.network),
            headers={"priv_key": new_publication.nautilus_private_key},
            json_payload=payload
        )

        if response is None:
            return None, info

        did = response.json().get("assetdid")
        return Publication(
            did=did,
            asset_key=asset_key,
            asset_url=asset_url,
            **new_publication.model_dump()
        ), info

    def revoke_publication(
            self, publication: Publication, nautilus_private_key: str
    ) -> Tuple[bool, str]:
        """Revoke a published asset in Nautilus."""
        url = urljoin(
            self._revocation_url,
            f"{publication.network}/{publication.did}"
        )
        response, info = self._post_request(
            url=url, headers={"priv_key": nautilus_private_key}
        )
        if response is None:
            return False, info

        return True, "success"
