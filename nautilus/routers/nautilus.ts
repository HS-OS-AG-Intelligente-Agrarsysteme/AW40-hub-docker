import { Router, Request, Response } from 'express'
import { json } from 'body-parser'
import { checkSchema, validationResult } from 'express-validator'
import { LogLevel, Nautilus, LifecycleStates } from '@deltadao/nautilus'
import { Network, NETWORK_CONFIGS, PRICING_CONFIGS } from '../config'
import { Wallet, providers } from 'ethers'
import { publishSchema } from '../schemas'
import * as dotenv from 'dotenv'
import { revoke, publishAccessDataset } from '../utils'

dotenv.config()

// load config based on selected network
if (!process.env.NETWORK) {
  throw new Error(
    `Set your networn in the .env file. Supported networks are ${Object.values(
      Network
    ).join(', ')}.`
  )
}
const selectedEnvNetwork = process.env.NETWORK.toUpperCase()
if (!(selectedEnvNetwork in Network)) {
  throw new Error(
    `Invalid network selection: ${selectedEnvNetwork}. Supported networks are ${Object.values(
      Network
    ).join(', ')}.`
  )
}
console.log(`Your selected NETWORK is ${Network[selectedEnvNetwork]}`)
const networkConfig = NETWORK_CONFIGS[selectedEnvNetwork]
const pricingConfig = PRICING_CONFIGS[selectedEnvNetwork]

// Setting up ethers wallet
const provider = new providers.JsonRpcProvider(networkConfig.nodeUri)

const assetdid_regex = new RegExp('did:op:[0-9a-z]{64}', 'g')

Nautilus.setLogLevel(LogLevel.Verbose)

export const nautilusrouter = Router()
nautilusrouter.use(json())

nautilusrouter.post(
  '/publish',
  checkSchema(publishSchema),
  async (req: Request, res: Response) => {
    const privateKey = req.get('priv_key')
    var err = validationResult(req)
    if (!err.isEmpty()) {
      res.send(err.mapped())
      return
    }
    const wallet = new Wallet(privateKey, provider)
    const nautilus = await Nautilus.create(wallet, networkConfig)
    const { asset_descr, service_descr } = req.body
    const result = await publishAccessDataset(
      nautilus,
      networkConfig,
      pricingConfig,
      wallet,
      service_descr,
      asset_descr
    )

    res.send({ result: result })
  }
)
nautilusrouter.post(
  '/revoke/:assetdid',
  async (req: Request, res: Response) => {
    const privateKey = req.get('priv_key')
    const assetdid = req.params.assetdid
    if (!assetdid_regex.test(assetdid)) {
      res.send({ error: 'Invalid asset did' })
      return
    }
    const wallet = new Wallet(privateKey, provider)
    const nautilus = await Nautilus.create(wallet, networkConfig)
    const result = await revoke(nautilus, assetdid)
    res.send({ result: result })
  }
)

nautilusrouter.get(
  '/download_url/:assetdid',
  async (req: Request, res: Response) => {
    const privateKey = req.get('priv_key')
    const assetdid = req.params.assetdid
    if (!assetdid_regex.test(assetdid)) {
      res.send({ error: 'Invalid asset did' })
      return
    }
    const wallet = new Wallet(privateKey, provider)
    const nautilus = await Nautilus.create(wallet, networkConfig)
    const url = await nautilus.access({
      assetDid: assetdid
    })
    res.send({ url: url })
  }
)
