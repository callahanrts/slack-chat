
ChannelView = require './conversations/channel-view'
MemberView = require './conversations/member-view'
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class ConversationView extends ScrollView
  @content: ->
    @div id: 'conversations', =>
      @div id: 'title', outlet: 'title'
      @ul id: 'channels', outlet: 'channelElements'
      @ul id: 'members', outlet: 'memberElements'

  initialize: (@stateController, @client) ->
    super
    @channelViews ||= []
    @memberViews ||= []
    @getChannels()
    @getMembers()
    @getTeamInfo()

  getChannels: () =>
    @client.get 'channels.list', {}, (err, resp) =>
      @channels = resp.body.channels
      @channelViews.push new ChannelView(@stateController, channel) for channel in @channels
      @channelElements.append(view) for view in @channelViews

  getMembers: (callback) =>
    @client.get 'im.list', {}, (err, resp) =>
      @members = resp.body.ims
      @memberViews.push new MemberView(@stateController, member) for member in @members
      @memberElements.append(view) for view in @memberViews

  getTeamInfo: =>
    @client.get 'team.info', {}, (err, resp) =>
      @title.append(@titleElement(resp.body.team))

  refresh: ->
    view.eventHandlers() for view in @memberViews
    view.eventHandlers() for view in @channelViews

  titleElement: (team) ->
    "<img id='teamIcon' src='#{team.icon.image_44}' /><h1>#{team.name}</h1>"
