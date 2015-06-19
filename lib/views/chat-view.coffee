
ChatMessageView = require './chat/chat-message-view'
ChatLogView = require './chat/chat-log-view'
{$, View} = require 'atom-space-pen-views'
imagesLoaded = require 'imagesloaded'

module.exports =
class ChatView extends View
  @content: (@stateController, @chat) ->
    image = @chat.image
    name = @chat.name

    @div class: 'chat', =>
      @div class: 'title', =>
        @span class: 'chevron-left back'
        @img class: 'teamIcon', src: image if image?
        @h1 name, class: "#{'channel' unless @chat.profile}"
      @div class: 'chat-log', outlet: 'chatLog'
      @div class: 'response-container', outlet: 'responseContainer', =>
        @textarea class: 'response', class: 'form-control native-key-bindings', outlet: 'response'

  initialize: (@stateController, @chat) ->
    @width(400)
    @type = if @chat.is_channel? then 'channels' else 'im'
    @getChatLog()
    @eventHandlers()

  closeChat: =>
    @stateController.setState('default')

  eventHandlers: =>
    @.on 'click', '.back', @closeChat
    @.on 'keyup', 'textarea', @keypress
    @.on 'focus', 'textarea', @setMark

  getChatLog: =>
    @stateController.client.get "#{@type}.history", { channel: @chat.channel.id }, (err, resp) =>
      @chatLogView = new ChatLogView(@stateController, resp.body.messages.reverse())
      @chatLog.append(@chatLogView)
      imagesLoaded @chatLogView, @update

  keypress: (e) =>
    if e.keyCode is 13 and not e.shiftKey
      @submit()
      return false
    @update()

  receiveMessage: (message) =>
    @chatLogView.receiveMessage(message)
    setTimeout @update, 0

  refresh: =>
    @eventHandlers()
    @update()

  setMark: =>
    type = if @chat.is_channel? then 'channels' else 'im'
    @stateController.client.post "#{type}.mark",
      channel: @chat.channel.id
      ts: Date.now()
    , (err, msg, resp) =>
      console.log err if err?
      if resp.ok
        $(message).removeClass('new slack-mark') for message in $(".message")


  submit: =>
    text = @response.val()
    @response.val('')
    @update()
    @stateController.client.post "chat.postMessage",
      channel: @chat.channel.id
      text: text
      as_user: @stateController.client.me.id
    , (err, msg, resp) =>
      console.log err if err?

  update: (e) =>
    @response.height(0)
    height = Math.min(@response.get(0).scrollHeight, 150)
    @response.height(height)
    @chatLog.css('padding-bottom', 50 + parseInt(@responseContainer.outerHeight()))
    @chatLog.scrollToBottom()
