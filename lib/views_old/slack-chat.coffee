SlackChatView = require './slack-chat-view'
AppServer = require './app_server.coffee'
{CompositeDisposable} = require 'atom'

SlackClient = require('./slack_client.coffee')
RTMClient = require('./rtm-client')

module.exports = SlackChat =
  slackChatView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @initializeDefaults()
    @appsvr = new AppServer()

    # Initialize clients with the appserver token. Won't need to be done again
    # since these classes are singletons
    new SlackClient(@appsvr.token)
    new RTMClient(@appsvr.token)

    # Main chat view
    @slackChatView = new SlackChatView()

    # @rtm.subscribe_to 'hello', ->
    #   console.log "subscribed"
    #   console.log arguments

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:toggle': =>
      @slackChatView.toggle()


  deactivate: ->
    # @modalPanel.destroy()
    # @subscriptions.dispose()
    # @slackChatView.destroy()

  serialize: ->
    slackChatViewState: @slackChatView.serialize()


  initializeDefaults: ->
    atom.config.set("slack-chat.show_on_right_side", true) unless atom.config.get('slack-chat.show_on_right_side')
    #username: '(AT) username'
    #icon_image: 'https://lh6.googleusercontent.com/WKDA-bQqAKuf0ONQrnbZNOqUv0ggpcOs4v6_U8kIEIO1gJRg_wzcV0ke4HmzNFrhVVc7wVK6FNA'
