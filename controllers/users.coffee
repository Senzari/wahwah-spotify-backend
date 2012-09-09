async   = require 'async'
util    = require 'util'
graph   = require 'fbgraph'
moniker = require 'moniker'
_       = require 'underscore'

class Users 
  constructor: (@app) -> 

  index: (req, resp) ->
    resp.send 'Users.index: ' + util.inspect req.query

  create: (req, resp) ->
    graph.setAccessToken req.body.token

    async.waterfall [
      (cb) ->
        query = 'SELECT uid, website, first_name, last_name, username, email, locale FROM user WHERE uid = me()'
        graph.fql query, (err, res) ->
          cb err, res
      (res, cb) ->
        fb =  _.first(res.data)
        db.models.User
          .create 
            spotify_id:   req.body.uuid
            facebook_id:  fb.uid
            firstname:    fb.first_name
            lastname:     fb.last_name
            username:     fb.username or moniker.choose()
            email:        fb.email
            locale:       fb.locale
            website:      fb.website
          .done (err, res) ->
            cb err, res
    ], 
    (err, res) ->
      console.log err
      console.log res

  update: (req, resp) ->
    resp.send 'Users.update'

  login: (req, resp) ->
    resp.send 'Users.login'

  logout: (req, resp) ->
    resp.send 'Users.logout'

  destroy: (req, resp) ->
    resp.send 'Users.destroy'


module.exports = (app) -> new Users(app)