module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "Channel",
    name:
      type: DataTypes.STRING
      allowNull: false
      validate:
        max: 64
        notNull: true
    status_message: 
      type: DataTypes.TEXT
      allowNull: true
    active:
      type: DataTypes.BOOLEAN
      allowNull: false
      defaultValue: false
      validate:
        notNull: true
  ,
    underscored: true
    paranoid: false
