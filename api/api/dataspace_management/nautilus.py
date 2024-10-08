import secrets
from typing import Optional
from uuid import uuid4

from ..data_management import Asset, Publication


class Nautilus:

    _publication_url: Optional[str] = None
    _market: str = "aw40-market"  # TODO: How is the market determined?

    def publish_access_dataset(
            self, asset_url: str, asset: Asset
    ) -> Publication:
        # Dummy data
        publication = Publication(
            did=str(uuid4()),
            market=self._market,
            asset_key=secrets.token_urlsafe(32),
            asset_url=asset_url
        )

        # TODO: Http request to nautilus connector at self._publication_url
        # https://github.com/deltaDAO/nautilus-examples/blob/main/publish.ts#L29
        return publication
