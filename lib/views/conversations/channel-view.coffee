
ChatView = require "../chat/chat-view"
{$, View} = require 'atom-space-pen-views'

module.exports =
class ChannelView extends View
  @content: (@parent, @channel) ->
    @li id: @channel.id, class: 'channel', click: 'showConversation', =>
      @span "#", class: 'indicator'
      @span @channel.name

  initialize: (@parent, @channel) ->

  showConversation: () ->
    new ChatView(@, @channel)
    console.log arguments
