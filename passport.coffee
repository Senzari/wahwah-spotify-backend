Strategy  = require('passport-facebook').Strategy
util      = require('util')

module.exports = 
  passport.use new Strategy 
    clientID: config.fb.client_id
    clientSecret: config.fb.client_secret
    callbackURL: 'http://localhost:5100/api/auth/callback'
    passReqToCallback: true
  , 
  (req, accessToken, refreshToken, profile, done) ->
    db.models.User
      .findOrCreate 
        facebook_id: profile._json.id 
      , 
        spotify_id: req.query.state or req.session.passport.uuid
        facebook_id: profile._json.id  
        firstname: profile._json.first_name
        lastname: profile._json.last_name
        username: profile._json.name or profile._json.username or moniker.choose()
        profile_url: profile._json.link
        email: profile._json.email
        locale: profile._json.locale
        timezone: profile._json.timezone
      .done (err, user) ->
        unless err
          user
            .setToken db.models.Token.build
              hash: accessToken
              provider: profile.provider
            .done (err, token) ->
              done err, user
        else 
          done err

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  db.models.User.find(id).done (err, user) ->
    done err, user

passport.isAuthenticated = (req, resp, next) ->
  unless req.isAuthenticated() 
    resp.json 403, message: 'you are not authorized for this!'
  else 
    next()

passport.isOwner = (req, resp, next) ->
  unless req.isAuthenticated() and req.params.uuid is req.user.spotify_id
    resp.json 403, message: 'you are not authorized for this!'
  else 
    next()

passport.isAdmin = (req, resp, next) ->
  unless req.isAuthenticated() and req.user.role is 'admin'
    resp.json 403, message: 'you are not authorized for this!'
  else 
    next()
