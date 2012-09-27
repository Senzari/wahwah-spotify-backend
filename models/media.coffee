module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "Media",
    public_id:
      type: DataTypes.STRING
      allowNull: false
      validate:
        isAlphamuneric: true
        notNull: true
    resource_type:
      type: DataTypes.STRING
      allowNull: false
      validate: 
        notNull: true
        whichType: (val) ->
          allowed = ['image', 'video']
          unless val in allowed
            throw new Error("Media Error - only #{allowed.join(', ')} media content allowed!")
    url:
      type: DataTypes.STRING
      allowNull: false
      validate:
        notNull: true
        isUrl: true
    url_small:
      type: DataTypes.STRING
      allowNull: true
      validate:
        isUrl: true
    url_large:
      type: DataTypes.STRING
      allowNull: true
      validate:
        isUrl: true
    format:
      type: DataTypes.STRING
      allowNull: true
      validate:
        whichFormat: (val) ->
          allowed = ['jpg', 'jpeg', 'png', 'gif']
          unless val in allowed
            throw new Error("Media Error - only #{allowed.join(', ')} images are allowed!") 
    category:
      type: DataTypes.STRING
      allowNull: false
      validate: 
        notNull: true
        whichCategory: (val) ->
          allowed = ['profile', 'channel']
          unless val in allowed
            throw new Error("Media Error - only media for users #{allowed.join(', ')} is allowed!")
  ,
    underscored: true
    paranoid: false
