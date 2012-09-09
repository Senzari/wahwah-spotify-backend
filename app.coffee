###
Module dependencies.
###
express   = require 'express'
http      = require 'http'
app       = module.exports = express()
server    = http.createServer app

###
Load the Config file
###

global.config = require('./config')
console.log process.env.NODE_ENV
console.log global.config

###
Express configuration
###

app.configure -> 
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router

app.configure 'development', ->
  app.use express.errorHandler dumpExceptions: true, showStack: true 
  config.db_options.logging = console.log

app.configure 'production', ->
  app.use express.errorHandler
  config.db_options.logging = false

###
Models
###

global.db = require('./database')(config.db_options)

###
Routes
###

routes = require('./routes')(app)

###
Http Server
###

if !module.parent
  server.listen process.env.PORT or 3000
  console.log "Express listening on port #{server.address().port}"