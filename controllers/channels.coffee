async      = require 'async'
cloudinary = require 'cloudinary'
uuid       = require 'node-uuid'
fs         = require 'fs'

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

  media: (req, resp) ->
    console.log "upload image to cloudinary"
    stream = cloudinary.uploader.upload_stream (result) ->
      console.log(result);
      res = cloudinary.image result.public_id, 
          format: "png", 
          width: 100, 
          height: 100, 
          crop: "fill" 

      resp.json res 

      fs
        .createReadStream req.files.image.path, encoding: 'binary'
        .on 'data', stream.write
        .on 'end', stream.end

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