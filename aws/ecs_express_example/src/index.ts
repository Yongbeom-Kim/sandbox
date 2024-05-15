import * as express from 'express'

const app = express()

console.log(process.env.PORT)
const PORT = process.env.PORT || 80;

app.get('/', (req, res) => {
  res.send('Hello World!')
})


app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`)
})