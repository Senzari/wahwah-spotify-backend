module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "Tag",
    tag:
      type: DataTypes.STRING
      allowNull: false
      validate:
        'is': ["[a-zA-Z\-\s\/]",'i']
        len: [2,24]
  ,
    underscored: true
    paranoid: false
