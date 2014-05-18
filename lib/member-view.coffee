{View} = require 'atom'

module.exports =
class MemberView extends View
  @content: (member) ->
    @li class: 'file entry list-item', =>
      @span class: 'icon glyphicon glyphicon-user'
      @span "#{member.name}", class: 'name', outlet: 'memberName'

  initialize: (@member) ->
    # @fileName.text(@file.name)
    # @fileName.attr('data-name', @file.name)
    # @fileName.attr('data-path', relativeFilePath)