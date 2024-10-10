import {
  Nautilus,
  ServiceBuilder,
  ServiceTypes,
  FileTypes,
  UrlFile,
  AssetBuilder
} from '@deltadao/nautilus'

import { NetworkConfig } from 'config'
import { Wallet } from 'ethers'

export async function publishAccessDataset(
  nautilus: Nautilus,
  networkConfig: NetworkConfig,
  pricingConfig: any,
  wallet: Wallet,
  service_descr: any,
  asset_descr: any
) {
  const { url, api_key, data_key, timeout } = service_descr
  const { name, type, description, author, license, price } = asset_descr

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
  var pricing = pricingConfig
  if (!(pricing.type === 'free')) {
    pricing.freCreationParams.fixedRate = price
  }
  const service = serviceBuilder
    .setServiceEndpoint(networkConfig.providerUri)
    .setTimeout(timeout)
    .addFile(urlFile)
    .setPricing(pricing)
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
    //.addCredentialAddresses(CredentialListTypes.ALLOW, [owner]) // OPTIONAL Configure access control to only allow the owner-address (0xabc...) to access the asset
    .build()

  const result = await nautilus.publish(asset)
  return result
}
