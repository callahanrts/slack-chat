
SlackChatView = require './views/slack-chat-view'
ConversationView = require './views/conversation-view'
ChatView = require './views/chat-view'

NotificationHandler = require './notification-handler'
Team = require './team'

{allowUnsafeEval} = require 'loophole'

module.exports =
class StateController
  slackChatView: null
  instance = null

  constructor: (@subscriptions) ->
    # Ensure there is only ever one instance of this class
    if instance
      return instance
    else
      instance = this

    @chatHistory = {}
    @stateHistory = []
    @state = null

    # Use loophole for external calls made within the SlackClient
    allowUnsafeEval =>
      SlackClient = require('sc-client').slackClient
      @token = atom.config.get('slack-chat.token')
      @client = new SlackClient(if @token is 'null' then null else @token)


    @slackChatView = new SlackChatView(@, @client)
    @modalPanel = atom.workspace.addRightPanel(item: @slackChatView, visible: false, className: 'slack-panel')

    @notifications = new NotificationHandler(@)

    @client.addSubscriber (message) =>
      msg = JSON.parse(message)
      @[msg.type]?(msg) # Call rtm method if it exists

  ####################################################
  # RTM Methods
  ####################################################
  hello: =>
    console.log 'hello'
    @team ||= new Team(@client) if @client # Gather slack team
    atom.config.set('slack-chat.token', @client.token)
    @setState('default')

  message: (message) =>
    @notifications.handleMessage(message)

  presence_change: (message) =>
    console.log message
    @team.setPresence(message.user, message.presence)
    @channelView.refresh() if @channelView


  ####################################################
  # View Methods
  ####################################################

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

  ####################################################
  # State Methods
  ####################################################
  setState: (state) =>
    state = state[0].toUpperCase() + state[1..-1].toLowerCase()
    @stateHistory.push @state if @state # keep track of state history
    @state = state
    @clearRoot()
    @["state#{state}"].apply(this, arguments)

  stateChat: (state, chatTarget) =>
    if @chatHistory[chatTarget.channel.id]
      @slackChatView.addView(@chatHistory[chatTarget.channel.id])
      @chatHistory[chatTarget.channel.id].refresh()
    else
      @chatHistory[chatTarget.channel.id] ||= new ChatView(@, chatTarget)
      @slackChatView.addView(@chatHistory[chatTarget.channel.id])

  preloadChat: (chat) =>
    @chatHistory[chat.id] ||= new ChatView(@, chat) if atom.config.get('slack-chat.preloadChat')

  updateChat: (message) =>
    console.log "update chat"
    if @chatHistory[message.channel]
      console.log "chat found"
      @chatHistory[message.channel].receiveMessage(message)

  stateDefault: =>
    @stateHistory = [] # No need to store previous states when we land at the default
    @channelView.refresh() if @channelView
    @channelView ||= new ConversationView(@, @client)
    @slackChatView.addView(@channelView)

  toggle: =>
    if @modalPanel.isVisible() then @modalPanel.hide() else @modalPanel.show()

