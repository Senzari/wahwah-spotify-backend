async   = require 'async'
_       = require 'underscore'

class Playlists 
  constructor: (@app) -> 

  create: (req, resp) ->
    console.log "playlists.create"
    if req.body.tracks and +req.params.cuid is +req.user.channel_id
      db.models.Track.emptyTracksFromPlaylist req.params.cuid, 
        (err) ->
          unless err
            async.forEachLimit req.body.tracks, 3, 
              (track, cb) ->
                db.models.Track
                  .create 
                    uri: track.uri
                    order: track.order
                    name: track.name
                    album: track.album
                    artist: track.artist
                    duration: track.duration
                    channel_id: req.params.cuid
                  .done cb
            ,
              (err) ->
                unless err
                  sql = db.module.Utils.format ['UPDATE "Channels" SET "playlist" = TRUE WHERE "id" = ?', req.params.cuid]
                  db.client
                    .query(sql, null, {raw: true})
                    .done (err, res) ->
                      if err
                        console.log err

                  resp.json 200, channel_id: req.params.cuid
                else 
                  console.log err
                  resp.json 500, message: error
          else 
            console.log err
            resp.json 500, new Error "internal!" 
    else 
      resp.json 403, new Error "please keep you hands in your own pocket!" 

  show: (req, resp) ->
    async.waterfall [
      (cb) ->
        db.models.Track
          .findAll 
            where: { channel_id: req.params.cuid }
            order: "order ASC"
          .done (err, tracks) ->
            cb err, tracks
        ### TODO
      (tracks, cb) ->
        async.forEachLimit tracks, 3, 
          (track, _cb) ->
            track
              .getTags()
              .done (err, tags) ->
                _track = track.toJSON()
                _track.tags = tags
                _cb err, _track
        ,
          (err, tracks) ->
            console.log tracks
            cb err, tracks
        ###
    ],
    (err, tracks) ->
      unless err
        resp.json tracks
      else
        resp.json 500, message: err


module.exports = (app) -> new Playlists(app)
