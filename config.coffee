module.exports = 
  db_options:
    schema:   process.env.DATABASE_NAME
    user:     process.env.DATABASE_USERNAME
    password: process.env.DATABASE_PASSWORD
    host:     process.env.DATABASE_HOST
    port:     process.env.DATABASE_PORT
    logging:  console.log
  fb_options:
    client_id:      '398920186828018'
    client_secret:  '2a4454df57adb05121b2a8eb612105f9'
    scope:          'email, user_about_me, user_birthday, user_location, publish_stream'