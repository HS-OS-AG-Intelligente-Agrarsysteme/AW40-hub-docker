import { Nautilus, LifecycleStates } from '@deltadao/nautilus'
import { initNautilus } from './init'
import { Network } from 'config'

export async function revoke(
  network: Network,
  assetdid: string,
  privateKey: string
) {
  const { nautilus } = await initNautilus(network, privateKey)
  const aquariusAsset = await nautilus.getAquariusAsset(assetdid)
  const tx = await nautilus.setAssetLifecycleState(
    aquariusAsset,
    LifecycleStates.REVOKED_BY_PUBLISHER
  )
  return tx
}
