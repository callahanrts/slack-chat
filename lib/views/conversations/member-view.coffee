
{$, View} = require 'atom-space-pen-views'

module.exports =
class MemberView extends View
  @content: (@stateController, @member) ->
    @li id: @member.id, class: 'member', outlet: 'conversation',  =>
      @span class: 'dot'
      @span @member.name

  initialize: (@stateController, @member) ->
    @eventHandlers()

  eventHandlers: =>
    @.on 'click', =>
      @showConversation()

  showConversation: () ->
    $("##{@member.id}").removeClass('unread')
    @stateController.setState('chat', @member)

