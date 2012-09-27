async      = require 'async'
cloudinary = require 'cloudinary'
uuid       = require 'node-uuid'
fs         = require 'fs'
handler    = require 'node-restify-errors'
_          = require 'underscore'

class Channels 
  constructor: (@app) -> 

  index: (req, resp) ->
    async.waterfall [
      (cb) ->
        db.models.Channel
          .findAll
            limit: 10
            where: 
              active: true
            order: "id DESC"
          .done cb
      (channels, cb) ->
        _channels = []
        async.forEachSeries channels, 
          (channel, _cb) ->
            db.models.Media
              .find
                attributes: ['public_id','url_small', 'url_large']
                where: 
                  user_id: channel.user_id
                  category: "profile"
                order: "id DESC"
              .done (err, media) ->
                _channel = channel.toJSON()
                _channel.media = media
                _channels.push _channel
                _cb err
        ,
          (err, channels) ->
            cb err, _channels
    ],
    (err, channels) ->
      unless err and channels is not null
        resp.json channels
      else 
        resp.json 500, new Error "arg!"


  media: (req, resp, next) ->
    if req.params.type in ["profile","channel"]
      stream = cloudinary.uploader.upload_stream (result) ->
        if result.error
          return resp.json 500, message: result.error.message

        small = cloudinary.url result.public_id,  
          format: "jpg" 
          width: 100 
          height: 100 
          crop: "fill" 
          gravity: "faces"
        
        large = ""
        if req.params.type is "profile"
          large = cloudinary.url result.public_id,  
            format: "jpg" 
            width: 190 
            height: 190 
            crop: "fill"
        else
          large = cloudinary.url result.public_id,  
            format: "jpg" 
            width: 1600 
            height: 1200 
            crop: "limit"

        async.waterfall [
          (cb) ->
            db.models.Media
              .findAll
                where: 
                  user_id: req.user.id 
                  resource_type: result.resource_type
                  category: req.params.type
              .done (err, files) ->
                for file in files
                  do (file) -> 
                    cloudinary.uploader.destroy file.public_id, 
                      -> console.log "cloudinary file deleted, id: "+file.public_id
                    file.destroy()
                cb err
          (cb) ->
            db.models.Media
              .create
                public_id: result.public_id
                resource_type: result.resource_type
                url: result.url
                url_small: small
                url_large: large
                format: result.format
                category: req.params.type
                user_id: req.user.id
              .done cb
        ], 
        (err, media) ->
          unless err 
            resp.json { type: req.params.type, small: small, large: large, public_id: result.public_id }
          else
            resp.json 500, message: err 

      path = _.first(req.files.user_file).path
      fs.createReadStream(path, encoding: 'binary')
        .on('data', stream.write)
        .on('end', stream.end)
    else
      next new handler.InvalidArgumentError("Sorry, media type is missing!")

  create: (req, resp) ->
    user = req.user   
    async.waterfall [
      (cb) ->
        channel = db.models.Channel
          .build
            user_id: user.id
            name: user.username
            status_message: "is listening to wahwah.fm!"
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
        if channel
          channel
            .getTags()
            .done (err, tags) ->
              channel.tags = tags
              cb err, channel
        else
          cb new Error("this channel doenst exist!")
    ],
    (err, channel) ->
      unless err
        _channel = channel.toJSON();
        _channel.tags = channel.tags
        resp.json _channel
      else
        resp.json 500, message: err



  update: (req, resp) ->

  destroy: (req, resp) ->


module.exports = (app) -> new Channels(app)