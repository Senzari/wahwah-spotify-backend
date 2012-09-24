Strategy  = require('passport-facebook').Strategy
util      = require('util')
async     = require('async')
handler   = require('node-restify-errors')
moniker   = require('moniker')

module.exports = 
  passport.use new Strategy 
    clientID: config.fb.client_id
    clientSecret: config.fb.client_secret
    callbackURL: 'http://localhost:5100/api/auth/callback'
    passReqToCallback: true
  , 
  (req, accessToken, refreshToken, profile, done) ->
    async.waterfall [
      # rebuild this using the non private parts and eventually 'fbgrap'
      (cb) ->
        db.models.User
          .find 
            where: { facebook_id: profile._json.id }
          .done (err, user) ->
            cb null, user

      (user, cb) ->
        unless user
          user = db.models.User
            .build
              facebook_id:  profile.id
              firstname:    profile.name.givenName
              lastname:     profile.name.familyName
              username:     profile._json.name or profile._json.username or moniker.choose()
              profile_url:  profile._json.link
              email:        profile._json.email
              locale:       profile._json.locale
              timezone:     profile._json.timezone
        else
          user.firstname    = profile.name.givenName
          user.lastname     = profile.name.familyName
          user.email        = profile._json.email
          user.locale       = profile._json.locale
          user.timezone     = profile._json.timezone

        unless err = user.validate()
          user
            .save()
            .done cb
        else 
          cb err

      (user, cb) ->
        user
          .setToken db.models.Token.build
            hash: accessToken
            provider: profile.provider
          .done (err, token) ->
            cb err, user

      (user, cb) ->
        db.models.Client
          .find
            # TODO: howto handle the query.state paramater? 
            # right know it doesn't get passed through from facebook/passport 
            where: { id: req.query.state, active: true }
          .done (err, client) ->
            # arg spaghetti carbonara - fix it!
            unless err
              if client 
                if client and client.user_id is null 
                  client.user_id = user.id
                  client
                    .save()
                    .done (err, client) ->
                      # TODO - Weiterleitung zur Success Page!
                      cb err, user
                else 
                  # TODO - Weiterleitung zur Success Page!
                  cb null, user
              else
                # TODO - Weiterleitung zur 'please request an invitation code seite' ...
                cb new handler.NotAuthorizedError "Sorry, but we are in the beta phase right now, please request an invitation code first!"
            else 
              cb err, user
    ],
    (err, user) ->
      unless err
        done null, user
      else 
        done err

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  db.models.User.find(id).done (err, user) ->
    done err, user

passport.isAuthenticated = (req, resp, next) ->
  unless req.isAuthenticated() 
    next new handler.NotAuthorizedError "Sorry, but this shit belongs not to you!"
  else 
    next()

passport.isOwner = (req, resp, next) ->
  unless req.isAuthenticated() and req.params.uuid is req.user.id
    next new handler.NotAuthorizedError "Sorry, but this shit belongs not to you!"
  else 
    next()

passport.isAdmin = (req, resp, next) ->
  unless req.isAuthenticated() and req.user.role is 'admin'
    next new handler.NotAuthorizedError "Sorry, but this shit belongs not to you!"
  else 
    next()
