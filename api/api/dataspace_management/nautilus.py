import secrets
from typing import Optional

import httpx

from ..data_management import Asset, Publication, NewPublication


class Nautilus:
    _publication_url: Optional[str] = None

    def __init__(self):
        if not self._publication_url:
            raise AttributeError("No Nautilus connection configured.")

    @classmethod
    def configure(cls, publication_url: str):
        """Configure nautilus connection details."""
        cls._publication_url = publication_url

    def publish_access_dataset(
            self,
            asset_url: str,
            asset: Asset,
            new_publication: NewPublication
    ) -> Publication:
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
                **new_publication.model_dump(
                    include={"license", "price"}
                )
            }
        }
        # Trigger the publication
        response = httpx.post(
            "/".join([self._publication_url, new_publication.network]),
            json=payload,
            headers={"priv_key": new_publication.nautilus_private_key}
        )
        # response.raise_for_status()  # TODO: Handle failures
        did = response.json().get("assetdid", "")

        return Publication(
            did=did,
            asset_key=asset_key,
            asset_url=asset_url,
            **new_publication.model_dump()
        )
