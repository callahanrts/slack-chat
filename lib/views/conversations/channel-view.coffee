
{$, View} = require 'atom-space-pen-views'

module.exports =
class ChannelView extends View
  @content: (@stateController, @channel) ->
    @li id: @channel.id, class: 'channel', =>
      @span "#", class: 'indicator'
      @span @channel.name

  initialize: (@stateController, @channel) ->
    @eventHandlers()

  eventHandlers: =>
    @.on 'click', =>
      @showConversation()

  showConversation: () ->
    console.log arguments
    @stateController.setState('chat', @channel)
