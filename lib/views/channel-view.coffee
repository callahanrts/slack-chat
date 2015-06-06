
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class ChannelView extends ScrollView
  @content: ->
    @div id: 'conversations', =>
      @ul id: 'channels', outlet: 'channelElements'
      @ul id: 'members', outlet: 'memberElements'

  initialize: (@parent, @client) ->
    super
    $.when(@getChannels())
      .then(@getMembers())

  getChannels: =>
    @client.get 'channels.list', {}, (err, resp) =>
      @channels = resp.body.channels
      @channelElements.append(@channelElement(channel)) for channel in @channels

  getMembers: =>
    @client.get 'users.list', {}, (err, resp) =>
      @members = resp.body.members
      @memberElements.append(@memberElement(member)) for member in @members

  channelElement: (obj) =>
    "<li id='#{obj.id}' class='channel'>#&nbsp; #{obj.name}</li>"

  memberElement: (obj) =>
    """
      <li id='#{obj.id}' class='member'>
        <span class="dot"></span>
        #{obj.name}
      </li>
    """

