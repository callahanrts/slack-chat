
{$, View} = require 'atom-space-pen-views'

module.exports =
class MemberView extends View
  @content: (@parent, @chat) ->
    @div 'chat stuff', id: 'chat'

  initialize: (@parent, @chat) ->


