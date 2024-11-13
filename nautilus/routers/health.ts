import { Router, Request, Response } from 'express'

export const healthrouter = Router()

healthrouter.get('/', async (req: Request, res: Response) => {
  res.send({ status: 'healthy' })
})
