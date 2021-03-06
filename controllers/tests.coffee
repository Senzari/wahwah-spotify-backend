async       = require 'async'
fs          = require 'fs'
cloudinary  = require 'cloudinary'

class Tests 
  constructor: (@app) -> 

  form: (req, resp) ->
      resp.send '
          <form method="post" enctype="multipart/form-data">
          <p>Public ID: <input type="text" name="title"/></p>
          <p>Image: <input type="file" name="image"/></p>
          <p><input type="submit" value="Upload"/></p>
          </form>'

  upload: (req, resp, next) ->
    stream = cloudinary.uploader.upload_stream (result) ->
      console.log(result)
      resp.send 'Done:<br/> <img src="' + result.url + '"/><br/>' + 
             cloudinary.image result.public_id, { format: "png", width: 100, height: 130, crop: "fill" }
    , { public_id: req.body.title } 
    fs
      .createReadStream(req.files.image.path, {encoding: 'binary'})
      .on('data', stream.write)
      .on('end', stream.end)

  sendmail: (req, resp, next) ->
    sendmail.send
      to: 'andreas@invertednothing.com'
      from: 'test@wahwah.fm'
      subject: 'hello world'
      text: req.query.text
    , 
      (success, message) ->
        console.log success
        console.log message
        if success
          resp.send 'worked!'
        else 
          resp.send 500, 'fuck!'
          
module.exports = (app) -> new Tests(app)