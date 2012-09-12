async = require 'async'

class Channels 
  constructor: (@app) -> 

  index: (req, resp) ->
    db.models.Channel
      .findAll
        limit: 10
      .done (err, channels) ->
        console.log channels 
        console.log req.user

    resp.json {hello:'test'}

  show: (req, resp) ->


  insert: (req, resp) ->


    #resp.send("test show")


module.exports = (app) -> new Channels(app)