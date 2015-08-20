
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
    @type =
      switch
        when @chat.is_channel? then 'channels'
        when @chat.is_group? then 'groups'
        when @chat.is_im? || @chat.is_owner? || @chat.is_admin? then 'im'
    @getChatLog()
    @eventHandlers()

  # Return to default state. One day this might just pop state
  closeChat: =>
    @stateController.setState('default')

  # Bind events for the chat view
  eventHandlers: =>
    @.on 'click', '.back', @closeChat
    @.on 'keyup', 'textarea', @keypress
    @.on 'focus', 'textarea', @setMark

  # Retrieve chat history on initialization
  getChatLog: =>
    @stateController.client.get "#{@type}.history", { channel: @chat.channel.id }, (err, resp) =>
      # View for managing chat logs
      console.log resp.body
      @chatLogView = new ChatLogView(@stateController, resp.body.messages.reverse(), @chat)
      @chatLog.append(@chatLogView) # Display logs
      imagesLoaded @chatLogView, @update # update (scroll down) after content has loaded (this excludes async content eg. open_graph)

  # Send message/create newline functionality for the textarea
  keypress: (e) =>
    if e.keyCode is 13 and not e.shiftKey
      @submit()
      return false
    @update()

  # Add the message to the chat log and update the view
  receiveMessage: (message) =>
    @chatLogView.receiveMessage(message)
    setTimeout @update, 0

  # Called when states change to ensure event handlers are active and
  # content is present/in place
  refresh: =>
    @eventHandlers()
    @update()

  # Mark the channel as read
  setMark: =>
    type =
      switch
        when @chat.is_channel? then 'channels'
        when @chat.is_group? then 'groups'
        when @chat.is_im? || @chat.is_owner? || @chat.is_admin? then 'im'
    @stateController.client.post "#{type}.mark",
      channel: @chat.channel.id
      ts: Date.now()
    , (err, msg, resp) =>
      console.log err if err?
      if resp.ok
        # Remove classes that show the section of unread messages
        $(message).removeClass('new slack-mark') for message in $(".message")


  # Send a message to a channel through the slack api and Update the view's state
  # accordingly.
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

  # Called all the time to make sure the view is in an optimal state
  update: (e) =>
    @response.height(0) # Set response height to 0 to calculate scroll height

    # Get the new height based off the scroll height for auto-resizing the textarea
    height = Math.min(@response.get(0).scrollHeight, 150)
    @response.height(height) # Set the new height

    # Update the chat log's padding to accomodate for textarea's change in height.
    # Also make sure the view is displaying the newest message (scroll to bottom)
    @chatLog.css('padding-bottom', 50 + parseInt(@responseContainer.outerHeight()))
    @chatLog.scrollToBottom()
