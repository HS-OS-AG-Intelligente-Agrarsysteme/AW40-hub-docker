from typing import Optional, Tuple

import httpx

from ..data_management import Asset, Publication


class Nautilus:
    _url: Optional[str] = None
    _timeout: Optional[int] = None  # Timeout for external requests to nautilus
    _api_key_assets: Optional[str] = None

    def __init__(self):
        if not self._url:
            raise AttributeError("No Nautilus connection configured.")

    @classmethod
    def configure(cls, url: str, timeout: int, api_key_assets: str):
        """Configure the nautilus connection details."""
        cls._url = url
        cls._timeout = timeout
        cls._api_key_assets = api_key_assets

    @property
    def _publication_url(self):
        return "/".join([self._url, "publish"])

    @property
    def _revocation_url(self):
        return "/".join([self._url, "revoke"])

    async def _post_request(
            self,
            url: str,
            headers: dict,
            json_payload: Optional[dict] = None
    ) -> Tuple[Optional[httpx.Response], str]:
        """
        Helper method to perform a POST request with standard error handling.
        """
        try:
            response = await httpx.AsyncClient().post(
                url, json=json_payload, headers=headers, timeout=self._timeout
            )
            response.raise_for_status()
            return response, "success"
        except httpx.TimeoutException:
            return None, "Connection timeout."
        except httpx.HTTPStatusError as e:
            return None, e.response.text

    async def publish_access_dataset(
            self, asset: Asset, nautilus_private_key: str
    ) -> Tuple[Optional[str], str]:
        """
        Publish an asset to Nautilus.
        """
        # Set up request payload
        payload = {
            "service_descr": {
                "url": asset.publication.asset_url,
                "api_key": self._api_key_assets,
                "data_key": asset.publication.asset_key
            },
            "asset_descr": {
                **asset.model_dump(
                    include={"name", "type", "description", "author"}
                ),
                "license": asset.publication.license,
                "price": {
                    "value": asset.publication.price,
                    "currency": "FIXED_EUROE"
                }
            }
        }
        # Attempt publication
        response, info = await self._post_request(
            url="/".join(
                [self._publication_url, asset.publication.network]
            ),
            headers={"priv_key": nautilus_private_key},
            json_payload=payload
        )
        # Publication failed. No did is returned.
        if response is None:
            return None, info

        # Publication successful. Did is returned.
        did = response.json().get("assetdid")
        return did, info

    async def revoke_publication(
            self, publication: Publication, nautilus_private_key: str
    ) -> Tuple[bool, str]:
        """Revoke a published asset in Nautilus."""
        url = "/".join(
            [self._revocation_url, publication.network, publication.did]
        )
        response, info = await self._post_request(
            url=url, headers={"priv_key": nautilus_private_key}
        )
        if response is None:
            return False, info

        return True, "success"
