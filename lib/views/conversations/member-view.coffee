
{$, View} = require 'atom-space-pen-views'

module.exports =
class MemberView extends View
  @content: (@stateController, @member) ->
    @li id: @member.id, class: 'member',  =>
      @span class: 'dot'
      @span @member.name

  initialize: (@stateController, @member) ->
    @eventHandlers()

  eventHandlers: =>
    @.on 'click', =>
      @showConversation()

  showConversation: () ->
    console.log arguments
    @stateController.setState('chat', @member)

