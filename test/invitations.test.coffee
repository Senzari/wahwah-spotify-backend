app       = require '../app'
chai      = require 'chai'
request   = require 'supertest'
expect    = chai.expect
should    = chai.should()    
 
# spotify_id: 1e2280d8058b91e18a9fc7f88fa6c2dea59151fd
# facebook token: AAABzaEEvm6oBAJtgO5y4v9ZC4VQWRojBIkYaEpmHjNhayrPHEhsoqRIz8M8tMCiOIMrauVo10oPd84cZBvPpVbcdLUpP5ces28RziGWSTp7SiaiyoT
request = request(app)

describe 'test invitations procedure', ->
  describe 'GET /api/auth/client', ->
    it 'missing query, should respond with status 500, msg', (done) ->
      request
        .get('/api/auth/client')
        .expect(500)
        .end (err, res) ->
          done err, res
    it 'should respond with status 200', (done) ->
      request
        .get('/api/auth/client')
        .query({ client_id: '1e2280d8058b91e18a9fc7f88fa6c2dea59151fd' })
        .expect(200)
        .end (err, res) ->
          done err, res
  describe 'POST /api/invitations/generate', ->
    it 'missing post data, should respond with status 500, msg', (done) ->
      request
        .post('/api/invitations/generate')
        .send({ client_id: '1e2280d8058b91e18a9fc7f88fa6c2dea59151fd' })
        .expect(500)
        .end (err, res) ->
          done err, res
    it 'invalid email, should respond with status 500, msg', (done) ->
      request
        .post('/api/invitations/generate')
        .send({ client_id: '1e2280d8058b91e18a9fc7f88fa6c2dea59151fd' })
        .send({ email: 'edwdew' })
        .expect(500)
        .end (err, res) ->
          done err, res
    it 'should respond with status 200', (done) ->
      request
        .post('/api/invitations/generate')
        .send({ client_id: '1e2280d8058b91e18a9fc7f88fa6c2dea59151fd' })
        .send({ email: 'andreas@invertednothing.com' })
        .expect(200)
        .end (err, res) ->
          done err, res
  describe 'GET /api/invitations/activate', ->
    it 'missing param, should respond with status 404, msg', (done) ->
      request
        .get('/api/invitations/activate')
        .expect(404)
        .end (err, res) ->
          done err, res
    it 'invalid param, should respond with alread send status msg', (done) ->
      request
        .get('/api/invitations/activate/5errwr3423')
        .expect(200)
        .expect('this invitation was already send! you can close this window now!')
        .end (err, res) ->
          done err, res
    it 'should respond with status 200', (done) ->
      db.models.Invitation
        .find(1)
        .done (err, invitation) ->
          if invitation
            request
              .get('/api/invitations/activate/'+invitation.code)
              .expect(200)
              .end (err, res) ->
                done err, res
          else 
            done new Error 'cant find a client'


