SlackChatView = require './slack-chat-view'
SlackAPI = require './slack-api'
$ = require 'jquery'
_ = require 'underscore-plus'

module.exports =
  configDefaults: 
    username: '(AT) username'
    token: 'xxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxx'
    icon_emoji_or_image: ':slack:'
  slackChatView: null

  activate: (state) ->
    @slack = new SlackAPI()
    @slackChatView = new SlackChatView(channels: @slack.channels(), slackTeam: @slack.team())
    atom.workspaceView.command "slack-chat:toggle", => 
      @slackChatView.toggle()

  deactivate: ->
    @slackChatView.destroy()

  serialize: ->
    slackChatViewState: @slackChatView.serialize()