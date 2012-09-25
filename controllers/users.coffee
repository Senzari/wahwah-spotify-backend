async   = require 'async'
util    = require 'util'
graph   = require 'fbgraph'
moniker = require 'moniker'
_       = require 'underscore'

class Users 
  constructor: (@app) -> 

  index: (req, resp) ->
    console.log "users.index"
    db.models.User
      .findAll
        #where: { active: true }
        attributes: ['id', 'username', 'locale', 'timezone', 'website', 'profile_url', 'twitter_url']
        offset: 0
        limit: 20
      .done (err, users) ->
        unless err
          resp.json users
        else 
          console.log "error"
          resp.json 500, message: err

  show: (req, resp) ->
    console.log "users.show"
    async.waterfall [
      (cb) ->
        db.models.User
          .find 
            where: { id: req.params.uuid }
            attributes: ['id', 'username', 'locale', 'timezone', 'website', 'profile_url', 'twitter_url']
          .done (err, user) ->
            if user
              cb err, user
            else 
              cb new Error('Sorry, the server has some hickups!')
      (user, cb) ->
          db.models.Media
            .find
              where: { user_id: user.id }
            .done (err, media) ->
              cb err, user, media
       (user, media, cb) ->
          db.models.Channel
            .find
              where: { user_id: user.id }
            .done (err, channel) ->
              user.channel = channel
              cb err, user, media, channel
    ],
    (err, user, media, channel) ->
      unless err

        rtn = user.toJSON()
        rtn.media = media.toJSON() if media
        rtn.channel = channel.toJSON() if channel

        resp.json rtn
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
