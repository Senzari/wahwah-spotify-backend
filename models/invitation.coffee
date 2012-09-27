module.exports = (Sequelize, DataTypes) ->
  Sequelize.define "Invitation",
    email:
      type: DataTypes.STRING
      allowNull: false
      validate: 
        isEmail: true
        notNull: true
    message:
      type: DataTypes.TEXT
      allowNull: true
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
  ,
    underscored: true
    paranoid: false
    instanceMethods:
      sendRegistrationMail: (cb) ->
        sendmail.send
          to: @email
          from: config.mail.from
          subject: "Your Registration on Spotify WahWah.fm"
          text: "balh blah blah"
        , cb

      sendActivationMail: (cb) ->
        sendmail.send
          to: @email
          from: config.mail.from
          subject: "Your Spotify WahWah.fm Invite Code"
          html: "
            balh blah blah, 
            please enter your invite code into the wahwah spotify app,
            blah blah blah .... 
            <a href='spotify:app:wahwah-prototype:profile'>#{@code}</a>
          "
        , cb

      sendAdminMail: (cb) ->
        sendmail.send
          to: config.mail.admin
          from: config.mail.from
          subject: "New Spotify Registrant"
          html: "
            <p>Hello WahWah Admin,<br>
            this is a automatic email from the WahWah Spotify backend, there is a new registrant and want's entry!</p>\n
            <p>#{@message}</p><br>
            <a href='http://localhost:5100/api/invitations/activate/#{@code}'>active</a>
          "
        , cb