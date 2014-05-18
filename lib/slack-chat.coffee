SlackChatView = require './slack-chat-view'
$ = require 'jquery'
_ = require 'underscore-plus'

module.exports =
  configDefaults: 
    username: '(AT) username'
    token: 'xxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxx'
    icon_emoji_or_image: ':slack:'
    show_on_right_side: true
  slackChatView: null

  activate: (state) ->
    @slackChatView = new SlackChatView()
    atom.workspaceView.command "slack-chat:toggle", => 
      @slackChatView.toggle()

  deactivate: ->
    @slackChatView.destroy()

  serialize: ->
    slackChatViewState: @slackChatView.serialize()