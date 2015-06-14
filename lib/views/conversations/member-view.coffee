
{$, View} = require 'atom-space-pen-views'

module.exports =
class MemberView extends View
  @content: (@stateController, @member) ->
    user = @stateController.team.members[@member.user]

    @li id: @member.id, class: 'member', outlet: 'conversation',  =>
      @span class: 'dot'
      if user?
        @span user.name
      else
        @span @member.user


  initialize: (@stateController, @member) ->
    @eventHandlers()

  eventHandlers: =>
    @.on 'click', =>
      @showConversation()

  showConversation: () ->
    $("##{@member.id}").removeClass('unread')
    @stateController.setState('chat', @member)

