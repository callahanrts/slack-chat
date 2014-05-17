ConversationView = require './conversation-view'
{View} = require 'atom'
$ = require 'jquery'
_ = require 'underscore-plus'

slackTeam = []
channels = []
ims = []

# Callahan
# token = "xoxp-2343778742-2343778744-2343809454-cb6720"

# Shortstack
# token = "xoxp-2268699755-2285215027-2304671872-f10511"

module.exports =
  class SlackChatView extends View
    conversationView: null

    constructor: ->
      @getChannels()
      @getTeam()
      super

    @content: ->
      @div class: 'slack-chat', =>
        @div 'Channels', class: 'title'
        @ul class: 'channels', =>
          console.log @channels
          @li "##{c.name}", class: 'channel' for c in channels

        @div 'Users', class: 'title'
        @ul class: 'users', =>
          @li "#{u.name}", class: 'member', 'data-id': u.id for u in slackTeam
    
    initialize: (serializeState) ->
      @conversationView = new ConversationView(=> @toggle())
      @.on 'click', '.member', (e) =>
        m = _.findWhere slackTeam, id: $(e.toElement).data('id')
        @conversationView.toggle(m)
        @toggle()
        
        # @sendMessage($(e.toElement).data('im'), "test message")

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      @detach()

    toggle: ->
      if @hasParent()
        @detach()
      else
        atom.workspaceView.appendToRight(this)    

    sendMessage: (im, message) ->
      regex = /:.{1,}:/
      icon = atom.config.get('slack-chat.icon_emoji_or_image')
      args = {
        token: atom.config.get('slack-chat.token')
        channel: im
        text: message
        username: atom.config.get('slack-chat.username')
      }
      if regex.test(icon)
        args.icon_emoji = icon
      else
        args.icon_image = icon

      $.get('https://slack.com/api/chat.postMessage', args).done (data) =>
        console.log data
          
    #################################################################################
    #
    # GET Methods
    # Should probably switch to deferreds or something later
    #################################################################################
    getChannels: ->
      unless channels.length > 0
        $.ajax
          async: false
          type: 'GET'
          url: "https://slack.com/api/channels.list?token=#{atom.config.get('slack-chat.token')}"
          success: (data) =>
            if data.ok is true
              for c in data.channels
                channels.push c

    getTeam: ->
      unless slackTeam.length > 0
        $.ajax
          async: false
          type: 'GET'
          url: "https://slack.com/api/users.list?token=#{atom.config.get('slack-chat.token')}"
          success: (data) =>
            if data.ok is true
              for m in data.members
                slackTeam.push m

    getIMs: ->
      unless slackTeam.length > 0 and slackTeam[0].im
        $.get 'https://slack.com/api/im.list', { token: atom.config.get('slack-chat.token') }
         .done (data) =>
            if data.ok is true
              for i in data.ims
                m = _.findWhere(slackTeam, {id: i.user})
                m.im = i if m
