
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

  # Show conversation when a member is selected
  showConversation: () ->
    # Mark as read and enter the chat state for this member
    $("##{@member.channel.id}").removeClass('unread')
    @stateController.setState('chat', @member)

  # Refresh the member view (when the state has changed)
  refresh: =>
    @eventHandlers() # update event handlers
    presence = @stateController.team.memberWithId(@member.id).presence # Aquire the member's presence
    @presence.removeClass('active away').addClass(presence) # Set the active/away class for the member

