async   = require 'async'
util    = require 'util'
uuid    = require 'node-uuid'
_       = require 'underscore'

class Invitations 
  constructor: (@app) -> 

  generate: (req, resp) ->
    async.waterfall [
      (cb) ->
        db.models.Client
          .find 
            where: { spotify_id: req.body.spotify_id or req.session.client.client_id }
          .done cb
      (client, cb) ->
        db.models.Invitation
          .find
            where: { client_id: client.client_id }
          .done (err, invitation) ->
            cb client, invitation
      (client, invitation, cb) ->
        invitation_code = uuid.v1()
        unless invitation
          invitation = db.models.Invitation
            .build
              code: invitation_code
              email: req.body.email
        else 
          invitation.code = invitation_code
        
        unless errors = invitation.validate()
          invitation
            .save()
            .done (err, invitation) ->
              cb err, client, invitation
        else 
          cb errors

      (client, invitation, cb) ->
        client
          .setInvitation(invitation)
          .done (err, client) ->
            invitation.sendRegistrationMail()
            cb err
    ],
    (err) ->
      unless err
        resp.send 200
      else
        resp.json 500, message: err

  register: (req, resp) ->
    async.waterfall [
      (cb) ->
        db.models.Invitation
          .find
            where: { code: req.body.code }
          .done cb
      (invitation, cb) ->
        db.models.Client
          .find
            where: { id: invitation.client_id }
          .done (err, client) ->
            cb err, client, invitation
      (client, invitation, cb) ->
        client.active = true
        client
          .save()
          .done (err, client) ->
            cb err, invitation
      (invitation, cb) ->
        invitation.sendActivationMail()
        cb null
    ],
    (err) ->
      unless err
        resp.send 200
      else
        resp.json 500, message: err

  activate: (req, resp) ->
    db.models.Invitation
      .find
        where: { code: req.params.code }
      .done (err, invitation) ->
        unless err
          invitation.send = true
          invitation.save()
          invitation.sendActivationMail()
          resp.send "user got his spotify wahwah.fm invitation code - you can close this window now!"
        else
          resp.json 500, message: err

module.exports = (app) -> new Invitations(app)

