module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "Track",
    uri:
      type: DataTypes.STRING
      allowNull: false
      validate:
        contains: "spotify:track"
        notNull: true
    order:
      type: DataTypes.INTEGER
      allowNull: false
    name:
      type: DataTypes.TEXT
      allowNull: false
      validate:
        notNull: true
        max: 1024
    album:
      type: DataTypes.TEXT
      allowNull: true
      validate:
        max: 5000
    artist:
      type: DataTypes.TEXT
      allowNull: true
      validate:
        max: 5000
    duration:
      type: DataTypes.INTEGER
      allowNull: true
      validate:
        isInt: true
  ,
    underscored: true
    paranoid: false
    classMethods:
      emptyTracksFromPlaylist: (channel_id, cb) ->
        sql = db.module.Utils.format ['DELETE FROM "Tracks" WHERE "channel_id" = ?', channel_id]
        db.client
          .query(sql, null, {raw: true})
          .done cb
