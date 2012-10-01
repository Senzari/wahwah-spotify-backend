module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "User",
    facebook_id:
      type: DataTypes.STRING
      allowNull: false
      unique: true
      validate: 
        isAlphanumeric: true
        notNull: true
    firstname: 
      type: DataTypes.STRING 
      allowNull: true
      validate:
        max: 255
    lastname:
      type: DataTypes.STRING 
      allowNull: true
      validate:
        max: 255
    username:
      type: DataTypes.STRING 
      allowNull: false
      validate:
        max: 128
        notNull: true
      #unique: true
    email:
      type: DataTypes.STRING 
      allowNull: true
      ###
      validate:
        isEmail: true
      ###
    locale:
      type: DataTypes.STRING
      allowNull: true
      ###
      validate:
        len: 5
      ###
    timezone:
      type: DataTypes.INTEGER
      validate:
        isInt: true
    website:
      type: DataTypes.STRING
      allowNull: true
      ###
      validate:
        isUrl: true
      ###
    profile_url:
      type: DataTypes.STRING
      allowNull: true
      validate:
        isUrl: true
    twitter_url:
      type: DataTypes.STRING
      allowNull: true
      ###
      validate:
        isUrl: true
      ###
    channel_id:
      type: DataTypes.INTEGER
      allowNull: true
    active:
      type: DataTypes.BOOLEAN
      allowNull: false
      defaultValue: false
      validate:
        notNull: true
  ,
    underscored: true
    paranoid: true