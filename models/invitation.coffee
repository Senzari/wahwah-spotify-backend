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
          subject: "thanks for your interest in WahWah.fm"
          html: " Hi there, we are happy to see you interested in your own wahwah.fm station on Spotify.<br/>
          We are going to inform you once we are ready to grant your application.<br/><br/>
          Music was our first love wahwah.fm<br/><br/>
          *************************** <br/>You want to get in touch with us? Just reply to this email. 
          "
        , cb

      sendActivationMail: (cb) ->
        sendmail.send
          to: @email
          from: config.mail.from
          subject: "your invite code"
          html: "
            Hi there, it is our pleasure to send you your personal invite code for your wahwah.fm station on Spotify.<br/>
            Just copy and paste this code, <a href='spotify:app:wahwah-prototype-live:invitation'>sign up</a> and you are ready to launch your own music channel.<br><br>
            Your invite code: #{@code}
            <br><br>
            We are looking forward to tune in. wahwah.fm<br/><br/>
            *************************** <br/>You want to get in touch with us? Just reply to this email. 
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
            <a href='http://wahwah-spotify.herokuapp.com/api/invitations/activate/#{@code}'>active</a>
          "
        , cb