###
Module dependencies.
###
express   = require 'express'
http      = require 'http'
passport  = require 'passport'
Strategy  = require('passport-facebook').Strategy
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
  app.use express.session { secret: 'mr scott' }
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use passport.initialize()
  app.use passport.session()
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
Passport Configuration
###

passport.use new Strategy 
    clientID: config.fb_options.client_id
    clientSecret: config.fb_options.client_secret
    callbackURL: 'http://wahwah-spotify.herokuapp.com/api/auth/callback/'
  , (accessToken, refreshToken, profile, done) ->
    console.log accessToken
    console.log refreshToken
    console.log profile
    done null, true

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  db.models.User.find(123).done (err, res) ->
    done err, res

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