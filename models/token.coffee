module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "Token",
    hash:
      type: DataTypes.STRING
      allowNull: false
      validate: 
        isAlphanumeric: true
    provider: 
      type: DataTypes.STRING
      allowNull: false
      validate: 
        notNull: true
        whichProvider: (val) ->
          allowed = ['facebook', 'twitter']
          unless val in allowed
            throw new Error("Token Error - only #{allowed.join(', ')} as auth providers are allowed!")
  ,
    underscored: true
    paranoid: false