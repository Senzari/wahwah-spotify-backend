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
  #app.set "jsonp callback", true
  #app.use express.logger()
  app.use express.static(__dirname + '/public')
  app.use express.cookieParser()
  app.use express.session({secret: config.app.hash_salt})
  app.use express.bodyParser()
  # nasty middleware/spine workarround - see https://github.com/senchalabs/connect/issues/415
  app.use (err, req, res, next) ->
    if err.message is 'invalid json' and req.method in ['GET','HEAD']
      next()
    else
      next(err)
  app.use express.methodOverride()
  app.use passport.initialize()
  app.use passport.session()

  app.use (req, resp, next) ->
    resp.header 'Access-Control-Allow-Origin', '*'
    resp.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
    resp.header 'Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, X-CSRF-Token'
    if req.method is 'OPTIONS'
      resp.send 200
    else
      next()

  app.use app.router

  app.use (err, req, resp, next) ->
    resp.header 'Access-Control-Allow-Origin', '*'
    resp.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
    resp.header 'Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, X-CSRF-Token'
    if err instanceof handler.RestError
      console.log err if err.statusCode is 500
      resp.json err.statusCode, err.body
    else if err
      next(err)
    else
      next()

app.configure 'development', ->
  app.use express.errorHandler dumpExceptions: true, showStack: true 
  config.db.logging = console.log

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
  console.log "Express listening on port #{server.address().port} - oh yeah!"
