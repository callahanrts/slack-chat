{View} = require 'atom'
$ = require 'jquery'

messages = []
module.exports =
  class ConversationView extends View

    @content: (member, messages) ->
      @div class: 'slack-chat', =>
        @span class: 'back glyphicon glyphicon-chevron-left',  click: 'toggle'
        @div "#{member.name}", class: 'title'
        @div id: 'messages', =>
          for m in messages
            console.log m
            @div m.username
            @div m.user
            @div m.text 
            @div m.ts
            @div '_____________________'
        @div id: 'message_input', =>
          @input id: 'msg', class: 'form-control'

    initialize: (member, messages, @callback) ->

      # @displayMessages(member)
      
    # displayMessages: (member) ->
    #   for message in @slack.messages(member.im.id)
    #     console.log message
    #     $('#messages').append("asdf")

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      @detach()

    toggle: ->
      if @hasParent()
        @detach()
        @callback()
      else
        atom.workspaceView.appendToRight(this)