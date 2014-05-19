{$, View} = require 'atom'
SlackAPI = require './slack-api'
MessageView = require './message-view'

module.exports =
  class ConversationView extends View
    @content: (member) ->
      @div class: 'conversation-view',  =>
        @span class: 'back glyphicon glyphicon-chevron-left',  click: 'toggle'
        @div "#{member.name}", class: 'title'
        @ol 
          class: 'slack-chat full-menu list-tree has-collapsable-children focusable-panel'
          tabindex: -1
          outlet: 'messages'

        @div id: 'message_input', =>
          @textarea id: 'msg', class: 'form-control', outlet: 'messageInput'

    initialize: (@member) ->
      @slack = new SlackAPI()
      @getMessages()
      console.log 'init'
  
    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      @detach()

    getMessages: ->
      for m in @slack.messages(@member.im.id)
        @messages.append new MessageView(m)
        
    focus: ->
      @messageInput.focus()
      
    hasFocus: ->
      @messageInput.is(':focus')
