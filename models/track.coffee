module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "Track",
    uri:
      type: DataTypes.STRING
      allowNull: false
      validate:
        contains: "spotify:track"
    name:
      type: DataTypes.TEXT
      allowNull: true
      validate:
        max: 1024
    duration:
      type: DataTypes.INTEGER
      allowNull: true
      validate:
        isInt: true
  ,
    underscored: true
    paranoid: true
