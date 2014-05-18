{View} = require 'atom'

module.exports =
class ChannelView extends View
  @content: (channel) ->
    @li class: 'file entry list-item', =>
      @span "#", class: 'icon'
      @span "#{channel.name}", class: 'name', outlet: 'channelName'

  initialize: (@channel) ->
    # @fileName.text(@file.name)
    # @fileName.attr('data-name', @file.name)
    # @fileName.attr('data-path', relativeFilePath)