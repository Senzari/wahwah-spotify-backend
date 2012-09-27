async   = require 'async'
util    = require 'util'
graph   = require 'fbgraph'
handler = require 'node-restify-errors'
_       = require 'underscore'

class Auth 
  constructor: (@app) -> 

  client: (req, resp, next) ->
    console.log "session"
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
          res = client.toJSON();
          res.loggedIn = req.isAuthenticated()
          req.session.client = res
          resp.json res
        else
          next err

  login: (req, resp, next) ->
    unless req.session.client 
      req.session.client = {}
      req.session.client.id = req.query.client_id
    passport.authenticate('facebook', { scope: ['user_status', 'user_photos'] })(req, resp, next)

  logout: (req, resp, next) ->
    req.logOut() 
    resp.json message: 'see you, byebye!'

  callback: (req, resp, next) ->
    console.log "facebook callback"
    passport.authenticate( 'facebook', { successRedirect: '/api/auth/login/done', failureRedirect: '/api/auth/login/failure' })(req, resp, next)

  done: (req, resp, next) -> 
    resp.send("welcome to wahwah!")

  failure: (req, resp, next) -> 
    resp.send("sorry something went wrong, please smoke some dope and calm down - we will fix it soon!")

module.exports = (app) -> new Auth(app)
