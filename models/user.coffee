module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "User",
    spotify_id:
      type: DataTypes.STRING
      allowNull: false
      unique: true
      validate: 
        isAlphanumeric: true
    facebook_id:
      type: DataTypes.STRING
      allowNull: false
      unique: true
      validate: 
        isAlphanumeric: true
    firstname: 
      type: DataTypes.STRING 
      allowNull: true
    lastname:
      type: DataTypes.STRING 
      allowNull: true
    username:
      type: DataTypes.STRING 
      allowNull: false
      #unique: true
    email:
      type: DataTypes.STRING 
      allowNull: true
      validate:
        isEmail: true
    locale:
      type: DataTypes.STRING
      allowNull: true
      validate:
        len: 5
    timezone:
      type: DataTypes.INTEGER
    website:
      type: DataTypes.STRING
      allowNull: true
      validate:
        isUrl: true
    profile_url:
      type: DataTypes.STRING
      allowNull: true
      validate:
        isUrl: true
    twitter_url:
      type: DataTypes.STRING
      allowNull: true
      validate:
        isUrl: true
    active:
      type: DataTypes.BOOLEAN
      allowNull: false
      defaultValue: false
  ,
    underscored: true
    paranoid: true