
ChatMessageView = require './chat/chat-message-view'
ChatLogView = require './chat/chat-log-view'
{$, View} = require 'atom-space-pen-views'

module.exports =
class ChatView extends View
  @content: (@stateController, @chat) ->
    user = @stateController.team.members[@chat.user]
    image = @stateController.team.memberImage(user, @chat)
    name = @stateController.team.memberName(user, @chat)

    @div id: 'chat', =>
      @div id: 'title', =>
        @span class: 'chevron-left back'
        @img id: 'teamIcon', src: image if image?
        @h1 name, class: "#{'channel' unless @chat.profile}"
      @div id: 'chat-log', outlet: 'chatLog'
      @div id: 'response-container', outlet: 'responseContainer', =>
        @textarea id: 'response', class: 'form-control native-key-bindings', outlet: 'response'

  initialize: (@stateController, @chat) ->
    @type = if @chat.is_channel? then 'channels' else 'im'
    @getChatLog()
    @stateController.slackChatView.addClass("chat")
    @eventHandlers()

  closeChat: =>
    @stateController.slackChatView.removeClass("chat")
    @stateController.previousState()

  eventHandlers: =>
    @.on 'click', '.back', @closeChat
    @.on 'keydown', '#response', @keypress
    @.on 'input', 'textarea', @update

    @update()

  getChatLog: =>
    @stateController.client.get "#{@type}.history", { channel: @chat.id }, (err, resp) =>
      @chatLogView = new ChatLogView(@stateController, resp.body.messages.reverse())
      @chatLog.append(@chatLogView)
      # NOTE: Need to install imagesloaded for this to work correctly
      @update()

  keypress: (e) =>
    if e.keyCode is 13 and not e.shiftKey
      @submit()
      return false

  receiveMessage: (message) =>
    @chatLogView.receiveMessage(message)
    @update()

  refresh: =>
    @eventHandlers()

  submit: =>
    text = @response.val()
    @response.val('')
    @stateController.client.post "chat.postMessage",
      channel: @chat.id
      text: text
      as_user: @stateController.client.me.id
    , (err, msg, resp) =>
      console.log arguments
      console.log err if err?

  update: (e) =>
    @response.height(0)
    height = Math.min(@response.get(0).scrollHeight, 150)
    @response.height(height)
    @chatLog.css('padding-bottom', 50 + parseInt(@responseContainer.outerHeight()))
    @chatLog.scrollToBottom()
