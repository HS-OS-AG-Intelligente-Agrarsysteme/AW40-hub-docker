import secrets
from typing import Optional

import httpx

from ..data_management import Asset, Publication, NewPublication


class Nautilus:
    _url: Optional[str] = None

    def __init__(self):
        if not self._url:
            raise AttributeError("No Nautilus connection configured.")

    @classmethod
    def configure(cls, url: str):
        """Configure nautilus connection details."""
        cls._url = url

    @property
    def _publication_url(self):
        return "/".join([self._url, "publish"])

    @property
    def _revocation_url(self):
        return "/".join([self._url, "revoke"])

    def publish_access_dataset(
            self,
            asset_url: str,
            asset: Asset,
            new_publication: NewPublication
    ) -> (Publication | None, str):
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
        try:
            # Trigger the publication
            response = httpx.post(
                "/".join([self._publication_url, new_publication.network]),
                json=payload,
                headers={"priv_key": new_publication.nautilus_private_key},
                timeout=120  # Takes a while due to roundtrip to pontus-x
            )
        except httpx.TimeoutException:
            # None return value indicates failed communication
            return None, "Connection timeout."

        if response.status_code // 100 != 2:
            # None return value indicates failed communication
            return None, response.text

        did = response.json()["assetdid"]
        return Publication(
            did=did,
            asset_key=asset_key,
            asset_url=asset_url,
            **new_publication.model_dump()
        ), "success"

    def revoke_publication(
            self, publication: Publication, nautilus_private_key: str
    ) -> (bool, str):
        try:
            # Revoke the publication
            response = httpx.post(
                "/".join(
                    [
                        self._revocation_url,
                        publication.network,
                        publication.did
                    ]
                ),
                headers={"priv_key": nautilus_private_key},
                timeout=120  # Takes a while due to roundtrip to pontus-x
            )
        except httpx.TimeoutException:
            # False indicates failed communication
            return False, "Connection timeout."
        if response.status_code // 100 != 2:
            # False indicates failed communication
            return False, response.text
        return True, "success"
