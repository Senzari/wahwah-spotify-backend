module.exports = 
  app:
    hash_salt: 'mr scott'
    limit_users_per_page: 20
  db:
    schema:   process.env.DATABASE_NAME
    user:     process.env.DATABASE_USERNAME
    password: process.env.DATABASE_PASSWORD
    host:     process.env.DATABASE_HOST
    port:     process.env.DATABASE_PORT
    logging:  console.log
  fb:
    client_id:      '434173479967591' #398920186828018
    client_secret:  '18cf0aca671e5d5ad70c149b09ca21df' #2a4454df57adb05121b2a8eb612105f9
    scope:          'email, user_about_me, user_birthday, user_location, publish_stream'
  mail:
    user:     process.env.SENDGRID_USERNAME
    password: process.env.SENDGRID_PASSWORD
    from:     'spotify@wahwah.fm'