import secrets
from typing import Optional

import httpx

from ..data_management import Asset, Publication


class Nautilus:

    _publication_url: Optional[str] = None
    _market: str = "aw40-market"  # TODO: How is the market determined?

    def __init__(self):
        if not self._publication_url:
            raise AttributeError("No Nautilus connection configured.")

    @classmethod
    def configure(cls, publication_url: str):
        """Configure nautilus connection details."""
        cls._publication_url = publication_url

    def publish_access_dataset(
            self, asset_url: str, asset: Asset
    ) -> Publication:
        # Generate a new asset key
        asset_key = secrets.token_urlsafe(32)
        # Trigger the publication
        response = httpx.post(
            self._publication_url,
            json={
                "type": "url",
                "method": "GET",
                "url": asset_url,
                "headers": {"asset_key": asset_key}
            }
        )
        response.raise_for_status()  # TODO: Handle failures
        did = ""  # TODO: Needs to be extracted from response

        return Publication(
            did=did,
            market=self._market,
            asset_key=asset_key,
            asset_url=asset_url
        )
