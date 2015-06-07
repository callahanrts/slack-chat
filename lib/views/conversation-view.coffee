
ChannelView = require './conversations/channel-view'
MemberView = require './conversations/member-view'
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class ConversationView extends ScrollView
  @content: ->
    @div id: 'conversations', =>
      @ul id: 'channels', outlet: 'channelElements'
      @ul id: 'members', outlet: 'memberElements'

  initialize: (@parent, @client) ->
    super
    @getChannels()
    @getMembers()

  initializeViews: =>
    console.log "init views", @channels

  getChannels: () =>
    @client.get 'channels.list', {}, (err, resp) =>
      @channels = resp.body.channels
      @channelElements.append(new ChannelView(@, channel)) for channel in @channels

  getMembers: (callback) =>
    @client.get 'users.list', {}, (err, resp) =>
      @members = resp.body.members
      @memberElements.append(new MemberView(@, member)) for member in @members

