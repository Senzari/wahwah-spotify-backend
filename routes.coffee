module.exports = (app) ->
  # Controller Instances
  Auth          = require('./controllers/auth.coffee')(app)
  Users         = require('./controllers/users.coffee')(app)
  Channels      = require('./controllers/channels.coffee')(app)
  Playlists     = require('./controllers/playlists.coffee')(app)
  Invitations   = require('./controllers/invitations.coffee')(app)

  # Welcome in the jungle
  app.get '/', (req, resp) -> 
    resp.send 'Welcome to the WahWah.fm Backbone!'
 
  # Routing for Channels
  app.get     '/api/channels', Channels.index
  #app.post    '/api/channels', passport.isAuthenticated, Channels.create
  app.post    '/api/channels/media/:type', passport.isAuthenticated, Channels.media
  app.post    '/api/channels/:cuid/media/:type', passport.isAuthenticated, Channels.media
  app.get     '/api/channels/:cuid', Channels.show
  app.put     '/api/channels/:cuid', passport.isAuthenticated, Channels.update
  app.delete  '/api/channels/:cuid', passport.isAuthenticated, Channels.destroy
  
  # Routing for Playlists
  app.get     '/api/playlists/:cuid', Playlists.show
  app.post    '/api/playlists/:cuid', passport.isAuthenticated, passport.isAuthenticated, Playlists.create
  
  # Routing for Users
  app.get     '/api/users', Users.index
  app.get     '/api/users/:uuid', Users.show
  app.put     '/api/users/:uuid', passport.isOwner, Users.update
  app.delete  '/api/users/:uuid', passport.isOwner, Users.destroy

  # Routing for Users Authentification
  app.get     '/api/auth/client', Auth.client
  app.get     '/api/auth/client/:client', Auth.client
  app.get     '/api/auth/dialog', Auth.dialog
  app.get     '/api/auth/login', Auth.login
  app.get     '/api/auth/logout', Auth.logout
  app.get     '/api/auth/callback', Auth.callback
  app.get     '/api/auth/login/done', Auth.done
  app.get     '/api/auth/login/failure', Auth.failure

  # Routing Invitation Code
  app.post    '/api/invitations/generate', Invitations.generate
  app.post    '/api/invitations/unlock', Invitations.unlock 
  app.get     '/api/invitations/activate/:code', Invitations.activate
    
  # Tests
  Tests       = require('./controllers/tests.coffee')(app)
  app.get     '/tests/sendmail', Tests.sendmail
  app.get     '/tests/upload', Tests.form
  app.post    '/tests/upload', Tests.upload

      