fs = require 'fs'

module.exports = (options) ->
  database = 
    options: options 
  
  # initialize the database
  Sequelize = require 'sequelize'
  database.module = Sequelize
  database.client = new Sequelize options.shema, options.user, options.password,
    host: options.host
    port: options.port
    protocol: 'postgres'
    dialect: 'postgres'
    maxConcurrentQueries: 100
    logging: options.logging

  # load models from the models directory 
  database.models = 
    User:     database.client.import(__dirname + '/models/user')
    Token:    database.client.import(__dirname + '/models/token')
    Channel:  database.client.import(__dirname + '/models/channel')
    Playlist: database.client.import(__dirname + '/models/playlist')
    Track:    database.client.import(__dirname + '/models/track')
    Tag:      database.client.import(__dirname + '/models/tag')
    Media:    database.client.import(__dirname + '/models/media')

  # setup model associations
  database.models.User
    .hasMany(database.models.Media, as: 'Media')
    .hasMany(database.models.Channel, as: 'Channels')
    .hasOne(database.models.Token)
    
  database.models.Channel
    .hasMany(database.models.Media, as: 'Media')
    .hasMany(database.models.Playlist, as: 'Playlists')
    .hasMany(database.models.Tag, as: 'Tags')
    
  database.models.Playlist
    .hasMany(database.models.Track, as: 'Tracks')
    .hasMany(database.models.Tag, as: 'Tags')

  database.models.Track
    .hasMany(database.models.Tag, as: 'Tags')

  database.models.Tag
    .hasMany(database.models.Channel, as: 'Channels')
    .hasMany(database.models.Playlist, as: 'Playlists')
    .hasMany(database.models.Track, as: 'Tracks')

  # sync schema to database
  database.client
    .sync({force:true})
    .error (error) ->
      console.log error
    .success () ->
      console.log 'database nsync'
  
  return database