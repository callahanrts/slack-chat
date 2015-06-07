
SlackChatView = require './views/slack-chat-view'
ConversationView = require './views/conversation-view'
ChatView = require './views/chat-view'
{allowUnsafeEval} = require 'loophole'

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

    @stateStack = []

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
    @slackChatView.remove(':not(.slack-wrapper)')

  destroyElements: =>
    @modalPanel.destroy()
    @slackChatView.destroy()

  getInstance: ->
    return instance

  getPanel: =>
    return @modalPanel

  previousState: ->
    @setState @stateStack.pop()

  setState: (state) =>
    state = state[0].toUpperCase() + state[1..-1].toLowerCase()
    @stateStack.push state # keep track of state history
    @["state#{state}"]()

  stateChat: =>
    @clearRoot()

  stateDefault: =>
    @clearRoot()
    @stateStack = [] # No need to store previous states when we land at the default
    @channelView ||= new ConversationView(@, @client)
    @slackChatView.append(@channelView)

  toggle: =>
    if @modalPanel.isVisible() then @modalPanel.hide() else @modalPanel.show()

