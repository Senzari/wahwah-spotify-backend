async     = require 'async'

class Channels 
  constructor: (@app) -> 

  index: (req, resp) ->
    db.models.Channel
      .findAll
        limit: 10
      .done (err, channels) ->
        console.log channels 
        console.log req.user

    resp.json hello:'test'

  create: (req, resp) ->
    user = req.user   
    async.waterfall [
      (cb) ->
        channel = db.models.Channel
          .build
            user_id: user.id
            name: user.username + " channel"
            status_message: user.username + " is listening to wahwah.fm!"
        unless errors = channel.validate()
          channel
            .save()
            .done (err, channel) ->
              cb err, channel
        else
          cb errors
      (channel, cb) ->
        user
          .addChannel(channel)
          .done (err, channel) ->
            cb err, channel
    ], 
    (err, channel) ->
      unless err 
        resp.send 200
      else
        resp.json 500, message: err 

  show: (req, resp) ->
    async.waterfall [
      (cb) ->
        db.models.Channel
          .find 
            where: { id: req.params.cuid }
          .done (err, channel) ->
            cb err, channel
      (channel, cb) ->
        db.models.Media
          .find
            where: { channel_id: channel.id }
          .done (err, media) ->
            channel.media = media
            cb err, channel
      (channel, cb) ->
        channel
          .getTags()
          .done (err, tags) ->
            channel.tags = tags
            cb err, channel
    ],
    (err, channel) ->
      unless err
        resp.json channel
      else
        resp.json 500, message: err



  update: (req, resp) ->

  destroy: (req, resp) ->


module.exports = (app) -> new Channels(app)