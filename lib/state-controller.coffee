
SlackChatView = require './views/slack-chat-view'
ConversationView = require './views/conversation-view'
ChatView = require './views/chat-view'
{allowUnsafeEval} = require 'loophole'

{$} = require 'atom-space-pen-views'

module.exports =
class StateController
  slackChatView: null
  instance = null

  constructor: ->
    # Ensure there is only ever one instance of this class
    if instance
      return instance
    else
      instance = this

    @stateHistory = []
    @state = null

    # Use loophole for external calls made within the SlackClient
    allowUnsafeEval =>
      SlackClient = require('sc-client').slackClient
      @client = new SlackClient(atom.config.get("sc-token"))

    @slackChatView = new SlackChatView(@, @client)
    @modalPanel = atom.workspace.addRightPanel(item: @slackChatView, visible: false, className: 'slack-panel')

    @client.addSubscriber (message) =>
      msg = JSON.parse(message)
      if msg.type is 'hello'
        atom.config.set('sc-token', @client.token)
        @setState('default')

  #Clear all child elements of the SlackChatView
  clearRoot: =>
    @slackChatView.clearViews()

  destroyElements: =>
    @modalPanel.destroy()
    @slackChatView.destroy()

  getInstance: ->
    return instance

  getPanel: =>
    return @modalPanel

  previousState: ->
    @setState @stateHistory.pop()

  setState: (state) =>
    state = state[0].toUpperCase() + state[1..-1].toLowerCase()
    @stateHistory.push @state if @state # keep track of state history
    @state = state
    @clearRoot()
    @["state#{state}"].apply(this, arguments)

  stateChat: (state, chatTarget) =>
    @chatView = new ChatView(@, chatTarget)
    @slackChatView.addView(@chatView)

  stateDefault: =>
    @stateHistory = [] # No need to store previous states when we land at the default
    @channelView.refresh() if @channelView
    @channelView ||= new ConversationView(@, @client)
    @slackChatView.addView(@channelView)

  toggle: =>
    if @modalPanel.isVisible() then @modalPanel.hide() else @modalPanel.show()

