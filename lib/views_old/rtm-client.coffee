{$} = require 'atom-space-pen-views'
WebSocket = require('ws')

module.exports =
class SlackClient
  SLACK_API = "https://slack.com/api"
  instance = null

  constructor: (token) ->
    # Ensure this class is a singleton
    return instance if instance
    instance = this

    # Maintain callbacks to methods which subscribe to slack notifications
    @subscriptions = []

    # Setup real time messaging
    @rtmUrl(token)

  @getInstance: ->
    return new @

  # Slack returns an rtm url we need to use to connect a websocket
  rtmUrl: (token) =>
    $.get "#{SLACK_API}/rtm.start", token: token
    .success (response) =>
      @webSocket response.url # Initialize web socket

  # Allow other classes to connect methods to messages received from slack
  subscribe_to: (message, method) ->
    @subscriptions.push (msg) ->
      method(msg) if msg.type is message

  # Initialize a websocket to listen for notifications from slack
  webSocket: (url) ->
    client = new WebSocket(url)
    client.on 'message', (msg) =>
      method(JSON.parse(msg)) for method in @subscriptions
