async = require 'async'

class Channels 
  constructor: (@app) -> 

  index: (req, resp) ->
    db.models.User
      .build 
        spotify_id: 'testid5'
        active: true
      .save()
      .success (acc) ->
        console.log acc 
    resp.json {hello:'test'}

  show: (req, resp) ->
    db.models.User
      .findAll
        limit: 10
        attributes: ['id', 'spotify_id']
      .success (accounts) ->
        resp.json accounts

  insert: (req, resp) ->
    db.models.User
      .findAll
        limit: 10
        attributes: ['id', 'spotify_id']
      .success (accounts) ->
        resp.json accounts


    #resp.send("test show")


module.exports = (app) -> new Channels(app)