
{$, View} = require 'atom-space-pen-views'

module.exports =
class ChatView extends View
  @content: (@stateController, @chat) ->
    @div id: 'chat', =>
      @div id: 'title', =>
        @img id: 'teamIcon', src: @chat.profile.image_32 if @chat.profile
        @h1 @chat.name, class: "#{'channel' unless @chat.profile}"
      @ul id: 'actions', =>
        @li 'All Conversations', class: 'action', click: 'closeChat'

  initialize: (@stateController, @chat) ->
    @stateController.slackChatView.addClass("chat")

  closeChat: =>
    @stateController.slackChatView.removeClass("chat")
    @stateController.previousState()


