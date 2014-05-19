{View} = require 'atom'

module.exports =
class MessageView extends View
  @content: (message) ->
    console.log message
    @div class: 'message', =>
      @div class: 'icon glyphicon glyphicon-envelope'
      @div "#{message.user}", class: 'name', outlet: 'memberName'
      @div "#{message.text}", class: 'name', outlet: 'memberName'
      @div "#{message.ts}", class: 'name', outlet: 'memberName'

  initialize: (@member) ->
    # @fileName.text(@file.name)
    # @fileName.attr('data-name', @file.name)
    # @fileName.attr('data-path', relativeFilePath)