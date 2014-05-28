{View} = require 'atom'

module.exports =
class ChannelView extends View
  @content: (channel) ->
    @li class: 'file entry list-item', =>
      @span "#", class: 'icon'
      @span "#{channel.name}", class: 'name', outlet: 'channelName'
      @span class: 'notifications', outlet: 'newMessages' #, =>
        # @span class: 'glyphicon glyphicon-envelope'
  
  initialize: (@channel) ->
