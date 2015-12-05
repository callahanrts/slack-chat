
WebSocket = require('ws')  # Websocket for rtm messaging through slack
needle = require('needle') # simple http requests
open = require('open')

module.exports =
class SlackClient

  constructor: (@clientId, @clientSecret, @token) ->
    @subscribers = []
    if @token is null
      if @clientId? and @clientSecret?
        open "https://slack.com/oauth/authorize?client_id=#{@clientId}&redirect_uri=#{@redirectUri()}&scope=read,post,client&state=scstate"
    else
      @rtmUrl()

  addSubscriber: (sub) =>
    @subscribers.push sub

  apiPath: (path, data) ->
    params = ""
    params += "&#{key}=#{val}" for key, val of data
    "https://slack.com/api/#{path}#{if params? then "?#{params.substring(1)}" else ""}"

  redirectUri: ->
    "http://slack-chat.herokuapp.com/slack/#{@clientId}/#{@clientSecret}"

  rtmUrl: =>
    needle.get @apiPath('rtm.start', { token: @token }), (err, resp) =>
      @team     = resp.body.team
      @ims      = resp.body.ims
      @channels = resp.body.channels
      @groups   = resp.body.groups
      @me       = resp.body.self
      @users    = resp.body.users
      @bots     = resp.body.bots
      @webSocket resp.body.url

  webSocket: (url) =>
    @client = new WebSocket(url)
    @client.on 'message', (message) =>
      sub(message) for sub in @subscribers

  get: (method, data={}, callback) ->
    data["token"] = @token
    needle.get @apiPath(method, data), (err, resp) =>
      callback(err, resp)

  post: (method, data={}, options={}, callback) ->
    data["token"] = @token
    needle.post @apiPath(method), data, options, (err, resp) =>
      callback(err, resp)
