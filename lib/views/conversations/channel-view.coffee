
{$, View} = require 'atom-space-pen-views'

module.exports =
class ChannelView extends View
  @content: (@stateController, @channel) ->
    @li id: @channel.id, class: 'channel', outlet: 'converations', =>
      @span "#", class: 'indicator'
      @span @channel.name

  initialize: (@stateController, @channel) ->
    @eventHandlers()

  eventHandlers: =>
    @.on 'click', =>
      @showConversation()

  # Show conversation when a channel is selected
  showConversation: () ->
    # Mark as read and enter the chat state for this channel
    $("##{@channel.id}").removeClass('unread')
    @stateController.setState('chat', @channel)
