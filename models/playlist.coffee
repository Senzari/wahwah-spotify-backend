module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "Playlist",
    hash:
      type: DataTypes.STRING
      allowNull: true
      validate:
        isAlphanumeric: true
        max: 64
    active:
      type: DataTypes.BOOLEAN
      allowNull: false
      defaultValue: false
  ,
    underscored: true
    paranoid: true
