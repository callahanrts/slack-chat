SlackChatView = require './slack-chat-view'
$ = require 'jquery'

slackTeam = []

module.exports =
  slackChatView: null

  activate: (state) ->
    @getTeam()
    @slackChatView = new SlackChatView(state.slackChatViewState)
    atom.workspaceView.command "slack-chat:send-message", => 
      member = @chooseMember()
      member.sendMessage('testing message')

  deactivate: ->
    @slackChatView.destroy()

  serialize: ->
    slackChatViewState: @slackChatView.serialize()

  getTeam: ->
    unless slackTeam.length > 0
      $.ajax({
        async: false,
        type: 'GET',
        url: 'https://slack.com/api/users.list?token=xoxp-2268699755-2285215027-2304671872-f10511'
        success: (data) ->
          if data.ok is true
            for m in data.members
              slackTeam.push new SlackMember(m)
      })

  chooseMember: ->
    slackTeam[0] if slackTeam.length > 0

class SlackMember
  constructor: (@data) ->
    
  sendMessage: (message) ->
    console.log @data.real_name, message