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
            attributes: ['id', 'username', 'locale', 'timezone', 'website', 'profile_url', 'twitter_url', 'active', 'channel_id']
          .done (err, user) ->
            if user
              cb err, user
            else 
              cb new Error('Sorry, the server has some hickups!')
      (user, cb) ->
          db.models.Media
            .findAll
              where: { user_id: user.id }
              order: 'id DESC'
            .done (err, media) ->
              cb err, user, media
       (user, media, cb) ->
          db.models.Channel
            .find
              where: { user_id: user.id }
              order: 'id DESC'
            .done (err, channel) ->
              user.channel = channel
              cb err, user, media, channel
    ],
    (err, user, media, channel) ->
      unless err
        _user = user.toJSON()
        _user.media = media
        _user.channel = channel

        resp.json _user
      else
        resp.json 500, message: err

  update: (req, resp) ->
    async.waterfall [
      (cb) ->
        channel = db.models.Channel
          .build
            name: req.body.name or req.user.username
            status_message: "is broadcasting on wahwah.fm"
            active: true
            user_id: req.user.id

        if req.user.channel_id
          channel.id = req.user.channel_id
          channel.isNewRecord = false

        channel
          .save()
          .done cb

      (channel, cb) ->
        req.user.username = req.body.name or req.user.username
        req.user.email = req.body.email 
        req.user.website = req.body.website
        req.user.twitter_url = req.body.twitter
        req.user.active = true
        req.user.channel_id = channel.id

        req.user
          .save()
          .done cb
    ],
      (err) ->
        unless err
          resp.json 200, req.user
        else 
          resp.json 500, message: err

  destroy: (req, resp) ->
    req.user.destroy()
    resp.json message: 'success'


module.exports = (app) -> new Users(app)
