import { Nautilus } from '@deltadao/nautilus'
import { initNautilus } from './init'
import { Network } from 'config'

export async function access(
  network: Network,
  assetdid: string,
  privateKey: string
) {
  const { nautilus } = await initNautilus(network, privateKey)
  const url = await nautilus.access({
    assetDid: assetdid
  })
  return url
}
