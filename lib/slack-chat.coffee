SlackChatView = require './slack-chat-view'
ChannelView = require './views/channel_view'

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


    @slackChatView = new SlackChatView(state.slackChatViewState)
    @modalPanel = atom.workspace.addRightPanel(item: @slackChatView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:toggle': => @toggle()

    @client.addSubscriber (message) =>
      msg = JSON.parse(message)
      if msg.type is 'hello'
        atom.config.set('sc-token', @client.token)
        @channelView = new ChannelView(@, @client)
        console.log @channelView.getElement()
        console.log ''
        console.log @slackChatView
        @slackChatView.appendChild(@channelView.getElement())
  #initializeViews: (parent, client) =>

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @slackChatView.destroy()

  serialize: ->
    slackChatViewState: @slackChatView.serialize()

  #stateChannelView: =>
  #  @slackChatView.appendChild(@channelView.getElement())
  #  console.log @slackChatView.getElement()

  toggle: ->
    console.log 'SlackChat was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
