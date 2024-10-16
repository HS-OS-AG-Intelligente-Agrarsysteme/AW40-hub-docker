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
  const result = await nautilus.setAssetLifecycleState(
    aquariusAsset,
    LifecycleStates.REVOKED_BY_PUBLISHER
  )
  return result
}

export async function changePrice(
  network: Network,
  assetdid: string,
  price: number,
  privateKey: string
) {
  const { nautilus } = await initNautilus(network, privateKey)
  const aquariusAsset = await nautilus.getAquariusAsset(assetdid)
  const result = await nautilus.setServicePrice(
    aquariusAsset,
    aquariusAsset.services[0].id,
    price.toString()
  )

  return result
}
