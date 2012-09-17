SendGrid = require('sendgrid').SendGrid
module.exports = new SendGrid config.mail.user, config.mail.password