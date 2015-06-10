
{$, View} = require 'atom-space-pen-views'

module.exports =
class MemberView extends View
  @content: (@stateController, @member) ->
    user = @stateController.team.members[@member.user]

    if user?
      @li id: @member.id, class: 'member',  =>
        @span class: 'dot'
        @span user.name
    else
      @li id: @member.id, class: 'member',  =>
        @span class: 'dot'
        @span @member.user


  initialize: (@stateController, @member) ->
    @eventHandlers()

  eventHandlers: =>
    @.on 'click', =>
      @showConversation()

  showConversation: () ->
    @stateController.setState('chat', @member)

