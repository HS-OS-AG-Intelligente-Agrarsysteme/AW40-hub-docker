import express, { Express } from 'express'
import { healthrouter, nautilusrouter } from './routers'
import swaggerUi from 'swagger-ui-express'
import swaggerDocument from './openapi.json'

const app: Express = express()
app.use('/nautilus', nautilusrouter)
app.use('/health', healthrouter)
if (process.env.USE_SWAGGER === 'true') {
  app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument))
}

const port = 3000

app.listen(port, () => {
  console.log(`Nautilus: Server is listening on port ${port}`)
})
