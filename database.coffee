fs      = require 'fs'
config  = require('./config')

module.exports = ->
  database = 
    options: config.db 
  
  # initialize the database
  Sequelize = require 'sequelize'
  database.module = Sequelize
  database.client = new Sequelize config.db.shema, config.db.user, config.db.password,
    host: config.db.host
    port: config.db.port
    protocol: 'postgres'
    dialect: 'postgres'
    maxConcurrentQueries: 100
    logging: config.db.logging

  # load models from the models directory 
  database.models = 
    User:       database.client.import(__dirname + '/models/user')
    Client:     database.client.import(__dirname + '/models/client')
    Token:      database.client.import(__dirname + '/models/token')
    Channel:    database.client.import(__dirname + '/models/channel')
    Track:      database.client.import(__dirname + '/models/track')
    Tag:        database.client.import(__dirname + '/models/tag')
    Media:      database.client.import(__dirname + '/models/media')
    Invitation: database.client.import(__dirname + '/models/invitation')

  # setup model associations
  database.models.Client
    .hasOne(database.models.User)
    .hasOne(database.models.Token)
    .hasOne(database.models.Invitation)

  database.models.User
    .hasMany(database.models.Media, as: 'Media')
    .hasMany(database.models.Channel, as: 'Channels')
    
  database.models.Channel
    .hasMany(database.models.Media, as: 'Media')
    .hasMany(database.models.Tag, as: 'Tags')
    .hasMany(database.models.Track, as: 'Tracks')
    
  database.models.Track
    .hasMany(database.models.Tag, as: 'Tags')

  database.models.Tag
    .hasMany(database.models.Channel, as: 'Channels')
    .hasMany(database.models.Track, as: 'Tracks')

  # sync schema to database
  database.client
    .sync({force: true})
    .error (error) ->
      console.log error
    .success ->
      console.log 'database nsync'
  
  return database