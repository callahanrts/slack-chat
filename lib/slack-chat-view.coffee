ConversationView = require './conversation-view'
SlackAPI = require './slack-api'
{View} = require 'atom'
$ = require 'jquery'
_ = require 'underscore-plus'

slackTeam = []
module.exports =
  class SlackChatView extends View
    conversationView: null

    @content: (params) ->
      slackTeam = params.slackTeam
      @div class: 'slack-chat', =>
        @div 'Channels', class: 'title'
        @ul class: 'channels', =>
          @li "##{c.name}", class: 'channel' for c in params.channels

        @div 'Users', class: 'title'
        @ul class: 'users', =>
          for u in params.slackTeam
            @li "#{u.name}", class: 'member', 'data-id': u.id, click: 'openConversation'
    
    initialize: (serializeState) ->
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

    openConversation: (e, el) ->
      member = _.findWhere(slackTeam, { id: $(el).data('id') })
      @slack = new SlackAPI()
      @conversationView = new ConversationView(member, @slack.messages(member.im.id), => @toggle())
      @conversationView.toggle()
      @toggle()
