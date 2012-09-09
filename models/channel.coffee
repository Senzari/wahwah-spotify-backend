module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "Channel",
    hash:
      type: DataTypes.STRING
      allowNull: true
      validate:
        isAlphanumeric: true
        max: 64
    name:
      type: DataTypes.STRING
      allowNull: true
      validate:
        max: 64
    status_message: 
      type: DataTypes.TEXT
      allowNull: true
      validate: 
        max: 1024
    active:
      type: DataTypes.BOOLEAN
      allowNull: false
      defaultValue: false
  ,
    underscored: true
    paranoid: true
