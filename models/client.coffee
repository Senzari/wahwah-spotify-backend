module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "Client",
    client_id:
      type: DataTypes.STRING
      allowNull: false
      autoIncrement: false
      validate: 
        isAlphanumeric: true
        notNull: true
    client:
      type: DataTypes.STRING
      allowNull: false
      defaultValue: 'spotify_app'
      validate: 
        notNull: true
        whichProvider: (val) ->
          allowed = ['spotify_app', 'web']
          unless val in allowed
            throw new Error("Token Error - only #{allowed.join(', ')} as clients are allowed!")
    active:
      type: DataTypes.BOOLEAN
      allowNull: false
      defaultValue: false
      validate:
        notNull: true
  ,
    underscored: true
    paranoid: false