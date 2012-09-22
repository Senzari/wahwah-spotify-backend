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
    client_id:      process.env.FACEBOOK_ID 
    client_secret:  process.env.FACEBOOK_SECRET
    scope:          'email, user_about_me, user_birthday, user_location, publish_stream'
  mail:
    user:     process.env.SENDGRID_USERNAME
    password: process.env.SENDGRID_PASSWORD
    from:     'spotify@wahwah.fm'
    admin:    'andreas@invertednothing.com'