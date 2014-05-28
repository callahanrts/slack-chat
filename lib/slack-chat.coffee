SlackChatView = require './slack-chat-view'
$ = require 'jquery'
_ = require 'underscore-plus'

module.exports =
  configDefaults: 
    username: '(AT) username'
    token: 'xxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxx'
    icon_image: 'https://lh6.googleusercontent.com/WKDA-bQqAKuf0ONQrnbZNOqUv0ggpcOs4v6_U8kIEIO1gJRg_wzcV0ke4HmzNFrhVVc7wVK6FNA'
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