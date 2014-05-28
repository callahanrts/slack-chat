{$, ScrollView} = require 'atom'
_ = require 'underscore-plus'
express = require('express');
bodyParser = require('body-parser')

module.exports =
  class SlackAPI
    constructor: ->
      @getChannels()
      @getTeam()
      
      @app = express();
      @app.use(bodyParser())
      @app.all '/*', (req, res, next) ->
        res.header("Access-Control-Allow-Origin", "*");
        res.header("Access-Control-Allow-Headers", "X-Requested-With");
        next();

      server = @app.listen 51932, () ->
        console.log('Listening on port %d', server.address().port);
        
      @app.post '/new', (req, res) =>
        @setNotifications(req.body.messages)
        res.send("success!")
        
      @last_ts = 0

    channels: ->
      @slackChannels
    
    team: ->
      @slackTeam
      
    messages: (channel, is_channel) ->
      @getMessages(channel, is_channel)
      @slackMessages.reverse()
      
    setNotifications: (messages) ->
      @subscriptions ||= []
      for n in @subscriptions
        n(messages)
        
    addMessageSubscription: (sub) ->
      @subscriptions ||= []
      @subscriptions.push sub
      
    removeMessageSubscription: (sub) ->
      @subscriptions = _.without @subscriptions, sub

    #################################################################################
    #
    # GET Methods
    # Should probably switch to deferreds or something later
    #################################################################################
    sendRequest: (params) ->
      $.ajax
        async: false
        type: 'GET'
        url: "https://slack.com/api/im.history?token=#{atom.config.get('slack-chat.token')}&channel=#{channel}"
        success: (data) =>
          params.success()

    getMessages: (channel, is_channel) ->
      t = if is_channel then 'channels' else 'im'
      $.ajax
        async: false
        type: 'GET'
        url: "https://slack.com/api/#{t}.history?token=#{atom.config.get('slack-chat.token')}&channel=#{channel}"
        success: (data) =>
          @slackMessages = if data.ok then data.messages else []
          @setMark(t, channel)
          
    # newestMessages: (channel, is_channel) ->
    #   t = if is_channel then 'channels' else 'im'
    #   $.ajax
    #     async: false
    #     type: 'GET'
    #     url: "https://slack.com/api/#{t}.history?token=#{atom.config.get('slack-chat.token')}&channel=#{channel}"
    #     success: (data) =>
    #       @slackMessages = data.messages if data.ok
    #       @setMark(t, channel)

    setMark: (path, channel) ->
      # Set mark when message is sent
      $.get("https://slack.com/api/#{path}.mark?token=#{atom.config.get('slack-chat.token')}&channel=#{channel}&ts=#{Date.now()}")

    getChannels: ->
      @slackChannels ||= []
      unless @slackChannels.length > 0
        $.ajax
          async: false
          type: 'GET'
          url: "https://slack.com/api/channels.list?token=#{atom.config.get('slack-chat.token')}"
          success: (data) =>
            if data.ok is true
              @slackChannels.push c for c in data.channels

    getTeam: ->
      @slackTeam ||= []
      unless @slackTeam.length > 0
        $.ajax
          async: false
          type: 'GET'
          url: "https://slack.com/api/users.list?token=#{atom.config.get('slack-chat.token')}"
          success: (data) =>
            if data.ok is true
              @slackTeam.push m for m in data.members
              @getIMs()

    getIMs: ->
      unless @slackTeam.length > 0 and @slackTeam[0].im
        $.get 'https://slack.com/api/im.list', { token: atom.config.get('slack-chat.token') }
         .done (data) =>
            if data.ok is true
              for i in data.ims
                m = _.findWhere(@slackTeam, {id: i.user})
                m.im = i if m
      
    sendMessage: (im, message) ->
      $.get('https://slack.com/api/chat.postMessage', {
        token: atom.config.get('slack-chat.token')
        channel: im
        text: message
        username: atom.config.get('slack-chat.username')
        icon_url: atom.config.get('slack-chat.icon_image')
      })
