module.exports = (app) ->
  # Controller Instances
  Auth      = require('./controllers/auth.coffee')(app)
  Users     = require('./controllers/users.coffee')(app)
  Channels  = require('./controllers/channels.coffee')(app)

  # Welcome in the jungle
  app.get '/', (req, resp) -> resp.send 'Welcome to the WahWah.fm Backbone!'
 
  # Routing for Channels
  app.get     '/api/channels', Channels.index
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
  app.get     '/api/auth/login', passport.authenticate('facebook', { scope: ['user_status', 'user_photos'] })
  app.get     '/api/auth/logout', (req, resp) -> req.logOut()
  app.get     '/api/auth/callback', passport.authenticate 'facebook'

  # Tests
  Tests       = require('./controllers/tests.coffee')(app)
  app.get     '/tests/upload', Tests.form
  app.post    '/tests/upload', Tests.upload