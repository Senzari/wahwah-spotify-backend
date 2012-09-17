async   = require 'async'
util    = require 'util'
graph   = require 'fbgraph'
_       = require 'underscore'

class Auth 
  constructor: (@app) -> 

  client: (req, resp, next) ->
    db.models.Client
      .findOrCreate 
        client_id: req.body.client_id 
      , 
        client: 'spotify_app'
        client_id: req.body.client_id 
      .done (err, client) ->
        unless err
          req.session.client = client
          resp.send 200
        else 
          resp.json 500, message: err

  login: (req, resp, next) ->
    req.session.passport.uuid = req.query.uuid
    passport.authenticate('facebook', { scope: ['user_status', 'user_photos'] })(req, resp, next)

  logout: (req, resp, next) ->
    req.logOut() 
    resp.json message: 'see you, byebye!'

  callback: (req, resp, next) ->
    passport.authenticate( 'facebook', { successRedirect: '/' })(req, resp, next)


module.exports = (app) -> new Auth(app)
