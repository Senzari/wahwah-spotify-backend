module.exports = (app) ->
  # Controller Instances
  Auth      = require('./controllers/auth.coffee')(app)
  Users     = require('./controllers/users.coffee')(app)
  Channels  = require('./controllers/channels.coffee')(app)

  # Welcome in the jungle
  app.get '/', (req, resp) -> resp.send 'Welcome to the WahWah.fm Backbone!'
 
  # Routing for Channels
  app.get     '/api/channels', passport.isAuthenticated, Channels.index
  app.post    '/api/channels', Channels.create
  app.get     '/api/channels/:uuid/:id', Channels.show
  app.put     '/api/channels/:uuid/:id', Channels.update
  app.delete  '/api/channels/:uuid/:id', Channels.destroy
  
  # Routing for Users
  app.get     '/api/users', Users.index
  app.post    '/api/users', Users.create
  app.put     '/api/users/:uuid', Users.update
  app.delete  '/api/users/:uuid', Users.destroy

  # Users Authentification
  # app.get     '/api/auth/login', passport.authenticate 'facebook', { scope: ['user_status', 'user_photos'] }
  app.get     '/api/auth/login', (req, resp, next) ->
    req.session.passport.uuid = req.query.uuid
    passport.authenticate('facebook', { scope: ['user_status', 'user_photos'] })(req, resp, next)

  app.get     '/api/auth/logout', (req, resp) -> 
    req.logOut() 
    resp.json message: 'see you, byebye!'

  app.get     '/api/auth/callback', (req, resp, next) -> 
    passport.authenticate( 'facebook', { successRedirect: '/' })(req, resp, next)

  # Tests
  Tests       = require('./controllers/tests.coffee')(app)
  app.get     '/tests/upload', Tests.form
  app.post    '/tests/upload', Tests.upload