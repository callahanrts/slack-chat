SlackChatView = require './views/slack-chat-view'
ChannelView = require './views/channel-view'

{CompositeDisposable} = require 'atom'

{allowUnsafeEval} = require 'loophole'

module.exports = SlackChat =
  slackChatView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    allowUnsafeEval =>
      SlackClient = require('sc-client').slackClient
      @client = new SlackClient(atom.config.get("sc-token"))


    @slackChatView = new SlackChatView(@, @client)
    @modalPanel = atom.workspace.addRightPanel(item: @slackChatView, visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:toggle', => @toggle()

    @client.addSubscriber (message) =>
      msg = JSON.parse(message)
      if msg.type is 'hello'
        atom.config.set('sc-token', @client.token)
        @channelView = new ChannelView(@, @client)
        @slackChatView.append(@channelView)

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @slackChatView.destroy()

  serialize: ->
    #slackChatViewState: @slackChatView.serialize()

  toggle: ->
    console.log 'SlackChat was toggled!'
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
