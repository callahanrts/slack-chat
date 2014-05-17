SlackChatView = require './slack-chat-view'

module.exports =
  configDefaults: 
    username: '(AT) username'
    token: 'xxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxx'
    icon_emoji_or_image: ':slack:'
  slackChatView: null

  activate: (state) ->
    @slackChatView = new SlackChatView(state.slackChatViewState)

  deactivate: ->
    @slackChatView.destroy()

  serialize: ->
    slackChatViewState: @slackChatView.serialize()

  chooseMember: ->
    slackTeam[0] if slackTeam.length > 0