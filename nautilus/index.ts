import express, { Express } from 'express'
import { healthrouter, nautilusrouter } from './routers'

const app: Express = express()
app.use('/nautilus', nautilusrouter)
app.use('/health', healthrouter)

const port = 3000

app.listen(port, () => {
  console.log(`Nautilus: Server is listening on port ${port}`)
})
