async   = require 'async'
util    = require 'util'
graph   = require 'fbgraph'
_       = require 'underscore'

class Auth 
  constructor: (@app) -> 

  index: (req, resp) ->
    resp.send 'Auth.index: ' + util.inspect req.query

  login: (req, resp) ->
    graph.setAccessToken req.query.token

    async.waterfall [
      (cb) ->
        query = 'SELECT uid, website, first_name, last_name, username, email, locale FROM user WHERE uid = me()'
        graph.fql query, (err, res) ->
          cb err, res
      (res, cb) ->
        fb =  _.first(res.data)
        db.models.User
          .create 
            spotify_id:   req.query.uuid
            facebook_id:  fb.uid
            firstname:    fb.first_name
            lastname:     fb.last_name
            username:     fb.username
            email:        fb.email
            locale:       fb.locale
            website:      fb.website
          .done (err, res) ->
            cb err, res
    ], 
    (err, res) ->
      console.log err
      console.log res

  logout: (req, resp) ->
    resp.send 'Auth.logout'

  callback: (req, resp) ->
    resp.send 'Auth.callback'


module.exports = (app) -> new Auth(app)