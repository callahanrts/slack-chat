# https://www.digitalocean.com/community/tutorials/how-to-write-a-linux-daemon-with-node-js-on-a-vps

{$} = require 'atom-space-pen-views'
{allowUnsafeEval, allowUnsafeNewFunction} = require 'loophole'
request = null
express = null
open = null

allowUnsafeEval =>
  request = require('request')
  express = require('express')
  open = require('open')


module.exports =
class AppServer
  PORT = 36347
  CLIENT_ID = "2343778742.4813733028"
  CLIENT_SECRET = "595cd179d4ecc534af9102a9a995c9be"
  REDIRECT_URI = "http://0.0.0.0:#{PORT}/oauth"

  constructor: (port) ->
    @app = express()

    @token = atom.config.get('slack-token')
    @getTokenFromSlack() unless @token

    @startServer()

  getTokenFromSlack: =>
    open "https://slack.com/oauth/authorize?client_id=#{CLIENT_ID}&redirect_uri=#{REDIRECT_URI}&scope=read,post,client&state=scstate&team=Callahan"
    @app.get '/oauth', (req, res) =>
      res.send "Using code: #{req.query.code} to get token"
      console.log "getting token now"

      # Exchange code for token
      $.get "https://slack.com/api/oauth.access",
        client_id: CLIENT_ID
        client_secret: CLIENT_SECRET
        code: req.query.code
        redirect_uri: REDIRECT_URI
      .done (response) =>
        @token = JSON.parse(body).access_token
        atom.config.set('slack-token', @token)

  startServer: =>
    server = @app.listen PORT, ->
      host = server.address().address
      port = server.address().port
