import { Router, Request, Response } from 'express'
import { json } from 'body-parser'
import {
  checkSchema,
  header,
  param,
  query,
  validationResult
} from 'express-validator'
import { Network, PRICING_CONFIGS } from '../config'
import { publishSchema } from '../schemas'
import { access, revoke, publishAccessDataset, initNautilus } from '../utils'

const privKeyValidator = header('priv_key').matches('^[0-9a-z]{64}$').hide()
const assetDidValidator = param('assetdid').matches('^did:op:[0-9a-z]{64}$')

const networkValidator = param('network')
  .toUpperCase()
  .custom(async (network) => {
    if (!(network in Network)) {
      throw new Error(`Unknown Network: '${network}'`)
    }
  })

export const nautilusrouter = Router()
nautilusrouter.use(json())

nautilusrouter.post(
  '/publish/:network',
  checkSchema(publishSchema),
  privKeyValidator,
  networkValidator,
  async (req: Request, res: Response) => {
    const err = validationResult(req)
    if (!err.isEmpty()) {
      res.status(400).send({ error: err.mapped() })
      return
    }

    const privateKey = req.get('priv_key')
    const { asset_descr, service_descr } = req.body
    const network = Network[req.params.network]
    const currency = asset_descr.price.currency

    if (!(currency in PRICING_CONFIGS[network])) {
      res.status(400).send({ error: `Unknown Currency: '${currency}'` })
      return
    }
    try {
      const result = await publishAccessDataset(
        network,
        service_descr,
        asset_descr,
        privateKey
      )

      res.status(201).send({ result: result })
    } catch (e) {
      console.log(e)
      res.status(500).send()
    }
  }
)
nautilusrouter.post(
  '/revoke/:network/:assetdid',
  assetDidValidator,
  privKeyValidator,
  networkValidator,
  async (req: Request, res: Response) => {
    const err = validationResult(req)
    if (!err.isEmpty()) {
      res.status(400).send({ error: err.mapped() })
      return
    }

    const privateKey = req.get('priv_key')
    const assetdid = req.params.assetdid
    const network = Network[req.params.network]
    try {
      const result = await revoke(network, assetdid, privateKey)
      res.status(200).send({ result: result })
    } catch (e) {
      console.log(e)
      res.status(500).send()
    }
  }
)

nautilusrouter.get(
  '/download_url/:network/:assetdid',
  assetDidValidator,
  privKeyValidator,
  networkValidator,
  async (req: Request, res: Response) => {
    const err = validationResult(req)
    if (!err.isEmpty()) {
      res.status(400).send({ error: err.mapped() })
      return
    }

    const privateKey = req.get('priv_key')
    const network = Network[req.params.network]
    const assetdid = req.params.assetdid
    try {
      const url = await access(network, assetdid, privateKey)
      res.status(200).send({ url: url })
    } catch (e) {
      console.log(e)
      res.status(500).send()
    }
  }
)
