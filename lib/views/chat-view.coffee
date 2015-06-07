
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
        @span class: 'chevron-left', click: 'closeChat'
        @img id: 'teamIcon', src: image if image?
        @h1 name, class: "#{'channel' unless @chat.profile}"
      @div id: 'chat-log', outlet: 'chatLog'
      @div id: 'response-container', outlet: 'responseContainer', =>
        @textarea id: 'response', class: 'form-control native-key-bindings', outlet: 'response', keydown: 'keypress'

  initialize: (@stateController, @chat) ->
    @type = if @chat.is_channel? then 'channels' else 'im'
    @getChatLog()
    @stateController.slackChatView.addClass("chat")

    setTimeout =>
      @update()
      @.on 'input', 'textarea', @update
    , 500

  getChatLog: =>
    @stateController.client.get "#{@type}.history", { channel: @chat.id }, (err, resp) =>
      @chatLog.append(new ChatLogView(@stateController, resp.body.messages.reverse()))

  closeChat: =>
    @stateController.slackChatView.removeClass("chat")
    @stateController.previousState()

  update: (e) =>
    @response.height(0)
    height = Math.min(@response.get(0).scrollHeight, 150)
    @response.height(height)
    @chatLog.css('padding-bottom', 50 + parseInt(@responseContainer.outerHeight()))
    @chatLog.scrollToBottom()

  keypress: (e) =>
    if e.keyCode is 13 and not e.shiftKey
      @submit()
      return false

  submit: =>
    @response.val('')
    @stateController.client.post "chat.postMessage",
      channel: @chat.id
      text: @response.val()
      as_user: @stateController.client.me.id
    , (err, msg, resp) =>
      console.log err if err?

