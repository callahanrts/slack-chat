ChannelView = require './channel-view'
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class SlackChatView extends ScrollView
  @content: ->
    @div class: 'slack-wrapper', =>
      @div id: 'title', outlet: 'title'

  initialize: (@parent, @client) ->
    super
    @width(400)
    @getTeamInfo()

  getTeamInfo: =>
    @client.get 'team.info', {}, (err, resp) =>
      @title.append(@titleElement(resp.body.team))

  titleElement: (team) ->
    "<img id='teamIcon' src='#{team.icon.image_44}' /><h1>#{team.name}</h1>"

