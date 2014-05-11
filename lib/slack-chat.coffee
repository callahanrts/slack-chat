SlackChatView = require './slack-chat-view'

module.exports =
  slackChatView: null

  activate: (state) ->
    @slackChatView = new SlackChatView(state.slackChatViewState)

  deactivate: ->
    @slackChatView.destroy()

  serialize: ->
    slackChatViewState: @slackChatView.serialize()
