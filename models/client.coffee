module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "Client",
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
    client_uid:
      type: DataTypes.STRING
      allowNull: false
      unique: true
      validate: 
        isAlphanumeric: true
        notNull: true
    active:
      type: DataTypes.BOOLEAN
      allowNull: false
      defaultValue: false
      validate:
        notNull: true
    underscored: true
    paranoid: false