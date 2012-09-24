async   = require 'async'
util    = require 'util'
graph   = require 'fbgraph'
handler = require 'node-restify-errors'
_       = require 'underscore'

class Auth 
  constructor: (@app) -> 

  client: (req, resp, next) ->
    if req.session.client
      if req.isAuthenticated() and !req.session.client.user_id
        req.session.client.user_id = req.user.id
      resp.json req.session.client
    else 
      async.waterfall [
        (cb) ->
          db.models.Client
            .find 
              where: { client_id: req.query.client_id }
            .done cb
        (client, cb) ->
          unless client
            client = db.models.Client
              .build
                client: 'spotify_app'
                client_id: req.query.client_id 
          
          unless errors = client.validate()
            client
              .save()
              .done cb
          else 
            cb new handler.InvalidArgumentError "Sorry, but your client has some hickups!"
      ],
      (err, client) ->
        unless err
          req.session.client = client
          resp.json client
        else
          next err

  login: (req, resp, next) ->
    passport.authenticate('facebook', { scope: ['user_status', 'user_photos'] })(req, resp, next)

  logout: (req, resp, next) ->
    req.logOut() 
    resp.json message: 'see you, byebye!'

  callback: (req, resp, next) ->
    passport.authenticate( 'facebook', { successRedirect: '/', failureRedirect: '/api/auth/login' })(req, resp, next)


module.exports = (app) -> new Auth(app)
