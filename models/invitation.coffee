module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "Invitation",
    email:
      type: DataTypes.STRING
      allowNull: false
      validate: 
        isEmail: true
        notNull: true
    code:
      type: DataTypes.STRING
      allowNull: false
      validate: 
        notNull: true
    send: 
      type: DataTypes.BOOLEAN
      allowNull: false
      defaultValue: false
      validate:
        notNull: true
    underscored: true
    paranoid: false
  ,
    instanceMethods:
      sendRegistrationMail: ->
        sendmail.send
          to: @email
          from: config.mail.from
          subject: "Your Registration on Spotify WahWah.fm"
          text: "balh blah blah"
      sendActivationMail: ->
        sendmail.send
          to: @email
          from: config.mail.from
          subject: "Your Spotify WahWah.fm Invite Code"
          text: "balh blah blah, #deeplink, code: #{@code}"