Strategy  = require('passport-facebook').Strategy

module.exports = 
  passport.use new Strategy 
    clientID: config.fb_options.client_id
    clientSecret: config.fb_options.client_secret
    callbackURL: 'http://localhost:5100/api/auth/callback'
    passReqToCallback: true
  , (req, accessToken, refreshToken, profile, done) ->

    (new db.module.Utils.QueryChainer)
      .add db.models.User
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
      .add db.models.Token.create
          hash: accessToken
          provider: profile.provider
      .run()
      .done (err, res) ->
        unless err
          [user, token] = res
          user
            .setToken(token) 
            .done (err, user) ->
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
    resp.json 403, message: 'your not logged in!'
  else 
    next()
