import { Nautilus, LifecycleStates } from '@deltadao/nautilus'

export async function revoke(nautilus: Nautilus, assetdid: string) {
  const aquariusAsset = await nautilus.getAquariusAsset(assetdid)
  const tx = await nautilus.setAssetLifecycleState(
    aquariusAsset,
    LifecycleStates.REVOKED_BY_PUBLISHER
  )
  return tx
}
