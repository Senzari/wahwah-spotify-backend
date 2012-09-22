async   = require 'async'
util    = require 'util'
graph   = require 'fbgraph'
moniker = require 'moniker'
_       = require 'underscore'

class Users 
  constructor: (@app) -> 

  index: (req, resp) ->
    # implement pagination - https://gist.github.com/926857
    db.models.User
      .findAll
        where: { active: true }
        offset: 0
        limit: 20
      .done (err, users) ->
        unless err
          resp.json users
        else 
          resp.json 500, message: err

  show: (req, resp) ->
    async.waterfall [
      (cb) ->
        db.models.User
          .find 
            where: { id: req.params.uuid }
            attributes: ['id','spotify_id', 'username', 'locale', 'timezone', 'website', 'profile_url', 'twitter_url']
          .done (err, user) ->
            cb err, user
      (user, cb) ->
        db.models.Media
          .find
            where: { user_id: user.id }
          .done (err, media) ->
            user.media = media
            cb err, user
    ],
    (err, user) ->
      unless err
        resp.json user
      else
        resp.json 500, message: err

  update: (req, resp) ->
    unless req.user.id is req.param.uuid
      return req.json 403, message: 'you are not authorized for this!'

    req.user.username = req.body.username
    req.user.email = req.body.email 
    req.user.validate()
    req.user
      .save()
      .done (err, user) ->
        unless err
          resp.json 204
        else 
          resp.json 500, message: err

  destroy: (req, resp) ->
    req.user.destroy()
    resp.json message: 'success'


module.exports = (app) -> new Users(app)
