Strategy  = require('passport-facebook').Strategy
util      = require('util')
async     = require('async')
handler   = require('node-restify-errors')
moniker   = require('moniker')

module.exports = 
  passport.use new Strategy 
    clientID: config.fb.client_id
    clientSecret: config.fb.client_secret
    callbackURL: config.fb.facebook_callback
    passReqToCallback: true
  , 
  (req, accessToken, refreshToken, profile, done) ->
    console.log "enter passport"
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
              greenhorn:    true
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
        # req.query.state
        if req.session.client
          client_id = req.session.client.id 
        else 
          client_id = req.query.state

        db.models.Client
          .find
            # TODO: howto handle the query.state paramater? 
            # right know it doesn't get passed through from facebook/passport 
            where: { id: client_id } #, active: true }
          .done (err, client) ->
            # arg spaghetti carbonara - fix it!
            unless err
              if client 
                if client and client.user_id is null 
                  client.user_id = user.id
                  client
                    .save()
                    .done (err, client) ->
                      cb err, user
                else 
                  cb null, user
              else
                client = db.models.Client
                  .create
                    client: 'spotify_app'
                    client_id: client_id
                    user_id: user.id
                    active: true
                  .done (err, client) ->
                    cb err, user
            else 
              cb err, user
    ],
    (err, user) ->

      unless err
        if req.session.client
          req.session.client.active   = true 
          req.session.client.loggedIn = true
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
  if req.isAuthenticated() and +req.params.uuid is +req.user.id
    next()
  else 
    next new handler.NotAuthorizedError "Sorry, but this shit belongs not to you!"
    
passport.isAdmin = (req, resp, next) ->
  if req.isAuthenticated() and req.user.role is 'admin'
    next()
  else 
    next new handler.NotAuthorizedError "Sorry, but this shit belongs not to you!"