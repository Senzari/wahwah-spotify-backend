async   = require 'async'
util    = require 'util'
uuid    = require 'node-uuid'
handler = require 'node-restify-errors'
_       = require 'underscore'

class Invitations 
  constructor: (@app) -> 

  generate: (req, resp, next) ->
    async.waterfall [
      (cb) ->
        db.models.Client
          .find 
            where: { client_id: req.body.client_id }
          .done cb

      (client, cb) ->
        unless client
          client = db.models.Client
            .build
              client: 'spotify_app'
              client_id: req.query.client_id 
        
          unless errors = client.validate()
            client
              .save()
              .done cb
          else 
            cb new handler.InvalidArgumentError "Sorry, but your client has some hickups!"
        else
          cb null, client

      (client, cb) ->
        client
          .getInvitation()
          .done (err, invitation) ->
            cb null, client, invitation

      (client, invitation, cb) ->
        invitation_code = uuid.v1()
        unless invitation
          invitation = db.models.Invitation
            .build
              code:     invitation_code
              message:  req.body.message
              email:    req.body.email
        else 
          invitation.email   = req.body.email
          invitation.message = req.body.message
          invitation.code    = invitation_code
        
        unless err = invitation.validate()
          invitation
            .save()
            .done (err, invitation) ->
              cb err, client, invitation
        else 
          cb new handler.InvalidArgumentError "Sorry, but this is not a valid email address!"

      (client, invitation, cb) ->
        unless invitation.client_id
          client
            .setInvitation(invitation)
            .done (err, client) ->
              invitation.sendRegistrationMail (success, message) ->
              invitation.sendAdminMail (success, message) ->
              cb err
        else 
          invitation.sendRegistrationMail (success, message) ->
          invitation.sendAdminMail (success, message) ->
          cb null
    ],
    (err) ->
      unless err
        resp.json 200
      else
        next err

  unlock: (req, resp, next) ->
    async.waterfall [
      (cb) ->
        db.models.Invitation
          .find
            where: { code: req.body.code }
          .done (err, invitation) ->
            if err 
              cb err
            else if not invitation
              cb new handler.InvalidArgumentError "Sorry, but this invitation code is not valid or already expired!"
            else 
              cb null, invitation

      (invitation, cb) ->
        db.models.Client
          .find
            where: { id: invitation.client_id }
          .done (err, client) ->
            if err 
              cb err
            else if not client
              cb new handler.NotAuthorizedError "Sorry, this client is not valid!"
            else 
              cb null, client, invitation

      (client, invitation, cb) ->
        if req.session.passport.client 
          req.session.passport.client.active = true

        client.active = true
        client
          .save()
          .done (err, client) ->
            cb err, invitation
    ],
    (err) ->
      unless err
        resp.json 200
      else
        next err

  activate: (req, resp, next) ->
    db.models.Invitation
      .find
        where: 
          code: req.params.code
          #send: true
      .done (err, invitation) ->
        unless err
          if invitation #and not invitation.send
            invitation.send = true
            invitation.save()
            invitation.sendActivationMail (success, message) ->
              resp.send "the user got his spotify wahwah.fm invitation code! you can close this window now!"
          else 
            resp.send "this invitation was already send! you can close this window now!"
        else
          resp.send 500, util.inspect err

module.exports = (app) -> new Invitations(app)

