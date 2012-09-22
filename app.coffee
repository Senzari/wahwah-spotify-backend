###
Module dependencies.
###
_         = require('underscore')
async     = require('async')
express   = require('express')
http      = require('http')
moniker   = require('moniker')
passport  = require('passport')
hashids   = require('hashids')
handler   = require('node-restify-errors')
app       = module.exports = express()
server    = http.createServer app

###
Load the Config file
###

global.config = require('./config')

###
Passport to Global
###
global.passport = passport

###
Express configuration
###

app.configure -> 
  app.use express.cookieParser()
  app.use express.session({secret: config.app.hash_salt})
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use passport.initialize()
  app.use passport.session()
  app.use express.logger()
  app.use app.router
  app.use (err, req, resp, next) ->
    if err instanceof handler.RestError
      console.log err if err.statusCode is 500
      resp.json err.statusCode, err.body
    else 
      console.log err
      resp.json 500, { code: 'internal', message: 'Sorry, an Internal Server Error occured!' }

app.configure 'development', ->
  app.use express.errorHandler dumpExceptions: true, showStack: true 
  config.db.logging = false #console.log

app.configure 'production', ->
  app.use express.errorHandler
  config.db.logging = false

app.locals
  hashes: new hashids config.app.hash_salt, 12

###
Models
###

global.db = require('./database')(config.db)

###
SendGrid Emails 
###

global.sendmail = require('./sendmail')

###
Passport 
###

require('./passport')

###
Routes
###

routes = require('./routes')(app)

###
Start up the Http Server
###

unless module.parent
  server.listen process.env.PORT or 3000
  console.log "Express listening on port #{server.address().port}"
