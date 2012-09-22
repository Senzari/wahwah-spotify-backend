async   = require 'async'
util    = require 'util'
graph   = require 'fbgraph'
handler = require 'node-restify-errors'
_       = require 'underscore'

class Auth 
  constructor: (@app) -> 

  client: (req, resp, next) ->
    if req.session.passport.client
      resp.json req.session.passport.client
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
            cb errors
      ],
      (err, client) ->
        unless err
          req.session.passport.client = client
          resp.json client
        else
          mext err

  login: (req, resp, next) ->
    req.session.passport.uuid = req.query.uuid
    passport.authenticate('facebook', { scope: ['user_status', 'user_photos'] })(req, resp, next)

  logout: (req, resp, next) ->
    req.logOut() 
    resp.json message: 'see you, byebye!'

  callback: (req, resp, next) ->
    passport.authenticate( 'facebook', { successRedirect: '/', failureRedirect: '/login' })(req, resp, next)


module.exports = (app) -> new Auth(app)
