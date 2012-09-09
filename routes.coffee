module.exports = (app) ->
  # Model Instances
  Auth      = require('./controllers/auth.coffee')(app)
  Users     = require('./controllers/users.coffee')(app)
  Channels  = require('./controllers/channels.coffee')(app)

  # Welcome in the jungle
  app.get '/', (req, resp) -> resp.send 'Welcome to the WahWah.fm Backbone!'
 
  # Routing for Channels
  app.get     '/api/channels', Channels.index
  app.post    '/api/channels', Channels.create
  app.get     '/api/channels/:id', Channels.show
  app.put     '/api/channels/:id', Channels.update
  app.delete  '/api/channels/:id', Channels.destroy
  
  # Routing for Users
  app.get     '/api/users', Users.index
  app.post    '/api/users', Users.create
  app.put     '/api/users/:uuid', Users.update
  app.delete  '/api/users/:uuid', Users.destroy

  # Users Authentification
  app.get     '/api/auth', Auth.index
  app.get     '/api/auth/login', Auth.login
  app.get     '/api/auth/logout', Auth.logout
  app.get     '/api/auth/callback', Auth.callback