import { Wallet, providers } from 'ethers'
import { LogLevel, Nautilus } from '@deltadao/nautilus'
import { Network, NETWORK_CONFIGS, PRICING_CONFIGS } from '../config'

export async function initNautilus(network: Network, privateKey: string) {
  const networkConfig = NETWORK_CONFIGS[network]
  const provider = new providers.JsonRpcProvider(networkConfig.nodeUri)
  const wallet = new Wallet(privateKey, provider)
  const nautilus = await Nautilus.create(wallet, networkConfig)
  const pricingConfigs = PRICING_CONFIGS[network]
  return { networkConfig, pricingConfigs, provider, wallet, nautilus }
}
