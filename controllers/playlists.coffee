async   = require 'async'
_       = require 'underscore'

class Playlists 
  constructor: (@app) -> 

  create: (req, resp) ->
    user = req.user   
    async.waterfall [
      (cb) ->
        db.models.Channel
          .find
            where: { id: req.params.cuid, user_id: user.id }
          .done (err, channel) ->
            cb err, channel
      (channel, cb) ->
        if channel
          chainer = new Sequelize.Utils.QueryChainer
          for track in req.body.tracks when track.id is null
            do (track) ->
              track.channel_id = channel.id
              chainer.add db.models.Track.create track
          chainer
            .runSerially()
            .done (err, track) ->
              cb err, channel
        else  
          cb new Error 'this channel does not exists or is not owed by you!', null
    ], 
    (err, channel) ->
      unless err 
        req.send 200
      else
        req.json 500, message: err

  show: (req, resp) ->
    async.waterfall [
      (cb) ->
        db.models.Track
          .findAll 
            where: { channel_id: req.params.cuid }
          .done (err, tracks) ->
            cb err, tracks
      (tracks, cb) ->
        tracks
          .getTags()
          .done (err, tags) ->
            tracks.tags = tags
            cb err, tracks
    ],
    (err, tracks) ->
      unless err
        resp.json tracks
      else
        resp.json 500, message: err


module.exports = (app) -> new Playlists(app)
