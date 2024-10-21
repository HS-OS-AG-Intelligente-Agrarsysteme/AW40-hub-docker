import {
  Nautilus,
  ServiceBuilder,
  ServiceTypes,
  FileTypes,
  UrlFile,
  AssetBuilder
} from '@deltadao/nautilus'

import { Network } from 'config'
import { Wallet } from 'ethers'

import { initNautilus } from './init'

export async function publishAccessDataset(
  network: Network,
  service_descr: any,
  asset_descr: any,
  privateKey: string
) {
  const { url, api_key, data_key, timeout } = service_descr
  const { name, type, description, author, license, price } = asset_descr
  const { nautilus, wallet, networkConfig, pricingConfigs } =
    await initNautilus(network, privateKey)
  const owner = await wallet.getAddress()
  const serviceBuilder = new ServiceBuilder({
    serviceType: ServiceTypes.ACCESS,
    fileType: FileTypes.URL
  })

  const urlFile: UrlFile = {
    type: 'url',
    url: url,
    method: 'GET',
    headers: {
      API_KEY: api_key,
      DATA_KEY: data_key
    }
  }
  const pricingConfig = pricingConfigs[price.currency]
  if (!(pricingConfig.type === 'free')) {
    pricingConfig.freCreationParams.fixedRate = price.value.toString()
  }
  const service = serviceBuilder
    .setServiceEndpoint(networkConfig.providerUri)
    .setTimeout(timeout)
    .addFile(urlFile)
    .setPricing(pricingConfig)
    .setDatatokenNameAndSymbol('Data Access Token', 'DAT') // important for following access token transactions in the explorer
    .build()

  const assetBuilder = new AssetBuilder()
  const asset = assetBuilder
    .setType(type)
    .setName(name)
    .setDescription(description)
    .setAuthor(author)
    .setLicense(license)
    .addService(service)
    .setOwner(owner)
    .build()

  const result = await nautilus.publish(asset)
  return result
}
