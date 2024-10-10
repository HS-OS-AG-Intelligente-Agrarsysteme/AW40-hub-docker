import { Router, Request, Response } from 'express'
import { json } from 'body-parser'
import {
  checkSchema,
  header,
  param,
  query,
  validationResult
} from 'express-validator'
import { Network } from '../config'
import { publishSchema } from '../schemas'
import { revoke, publishAccessDataset, initNautilus } from '../utils'

const assetdid_regex = new RegExp('^did:op:[0-9a-z]{64}$', 'g')
const privkey_regex = new RegExp('^[0-9a-z]{64}$', 'g')

export const nautilusrouter = Router()
nautilusrouter.use(json())

nautilusrouter.post(
  '/publish',
  checkSchema(publishSchema),
  header('priv_key').matches(privkey_regex),
  async (req: Request, res: Response) => {
    try {
      validationResult(req).throw()
      const privateKey = req.get('priv_key')
      const { asset_descr, service_descr } = req.body
      const network = service_descr.network
      if (!(network in Network)) {
        res.send({ error: `Unknown Network: '${network}'` })
        return
      }
      const { networkConfig, pricingConfigs, wallet, nautilus } =
        await initNautilus(Network[network], privateKey)
      const currency = asset_descr.price.currency
      if (!(currency in pricingConfigs)) {
        res.send({ error: `Unknown Currency: '${currency}'` })
        return
      }
      const pricingConfig = pricingConfigs[currency]
      const result = await publishAccessDataset(
        nautilus,
        networkConfig,
        pricingConfig,
        wallet,
        service_descr,
        asset_descr
      )

      res.send({ result: result })
    } catch (err) {
      res.send({ error: err.mapped() })
    }
  }
)
nautilusrouter.post(
  '/revoke/:network/:assetdid',
  param('assetdid').matches(assetdid_regex),
  header('priv_key').matches(privkey_regex),
  param('network')
    .toUpperCase()
    .custom(async (network) => {
      if (!(network in Network)) {
        throw new Error(`Unknown Network: '${network}'`)
      }
    }),
  async (req: Request, res: Response) => {
    try {
      validationResult(req).throw()
      const privateKey = req.get('priv_key')
      const { assetdid, network } = req.params
      const { nautilus } = await initNautilus(Network[network], privateKey)
      const result = await revoke(nautilus, assetdid)
      res.send({ result: result })
    } catch (err) {
      res.send({ error: err.mapped() })
    }
  }
)

nautilusrouter.get(
  '/download_url/:network/:assetdid',
  param('assetdid').matches(assetdid_regex),
  header('priv_key').matches(privkey_regex),
  param('network')
    .toUpperCase()
    .custom(async (network) => {
      if (!(network in Network)) {
        throw new Error(`Unknown Network: '${network}'`)
      }
    }),
  async (req: Request, res: Response) => {
    try {
      validationResult(req).throw()
      const privateKey = req.get('priv_key')
      const network = req.params.network
      const assetdid = req.params.assetdid
      const { nautilus } = await initNautilus(Network[network], privateKey)
      const url = await nautilus.access({
        assetDid: assetdid
      })
      res.send({ url: url })
    } catch (err) {
      res.send({ error: err.mapped() })
    }
  }
)
