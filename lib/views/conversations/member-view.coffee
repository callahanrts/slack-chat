
{$, View} = require 'atom-space-pen-views'

module.exports =
class MemberView extends View
  @content: (@stateController, @member) ->
    @li id: @member.channel.id, class: 'member', outlet: 'conversation',  =>
      @span class: "dot #{@member.presence}", outlet: 'presence'
      @span @member.name

  initialize: (@stateController, @member) ->
    @eventHandlers()

  eventHandlers: =>
    @.on 'click', =>
      @showConversation()

  showConversation: () ->
    $("##{@member.channel.id}").removeClass('unread')
    @stateController.setState('chat', @member)

  refresh: =>
    @eventHandlers()
    presence = @stateController.team.memberWithId(@member.id).presence
    @presence.removeClass('active away').addClass(presence)

