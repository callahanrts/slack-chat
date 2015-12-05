
SlackChatView = require './views/slack-chat-view'
ConversationView = require './views/conversation-view'
ChatView = require './views/chat-view'
FileManager = require './file-manager'
FileUploadView = require './views/file-upload-view'
SlackClient = require('./slack-client')

notifier = require 'node-notifier'
Team = require './team'

{$} = require 'atom-space-pen-views'
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

    # Retrieve slack token if we've previously authenticated a user
    token = atom.config.get('slack-chat.api_token')
    token = if token is 'null' then null else token

    clientId = atom.config.get('slack-chat.api_key')
    clientId = if clientId is 'null' then null else clientId

    clientSecret = atom.config.get('slack-chat.api_secret')
    clientSecret = if clientSecret is 'null' then null else clientSecret
    @client = new SlackClient(clientId, clientSecret, token)

    # Create main view for the slack-chat package and bind it to the right modal panel
    @slackChatView = new SlackChatView(@, @client)
    @modalPanel = atom.workspace.addRightPanel(item: @slackChatView, visible: false, className: 'slack-panel')

    # Subscribe to notifications from the RTM slack api. The client connects to the RTM api
    # using a websocket and calls subscribers when shit happens
    @client.addSubscriber (message) =>
      msg = JSON.parse(message)
      @[msg.type]?(msg) # Call rtm method if it exists

  ####################################################
  # RTM Methods
  ####################################################
  hello: =>
    # Anything that should be initialized after slack is all connected should
    # be initialized here. This is the first method called from the rtm client
    # after being connected
    console.log 'hello'
    @team ||= new Team(@client) if @client # Gather slack team
    @fileManager = new FileManager(@) # Create file upload manager; could probably be initialized elsewhere
    atom.config.set('slack-chat.api_token', @client.token) # save slack token
    @setState('default') # enter default slack-chat state

  message: (message) =>
    @updateChat(message)
    unless message.user is @client.me.id
      # Mark the channel as unread so it is highlighted
      $("##{message.channel}", @channelView).addClass("unread")

      # Find the member that sent the message
      member = @team.memberWithId(message.user)

      # Send growl/native/whatever notifications when a message has been received
      if atom.config.get('slack-chat.notifications') and member?
        notifier.notify
          title: "New message from #{member.name}",
          message: "#{message.text.substring(0,140)}"
          icon: "https://raw.githubusercontent.com/callahanrts/slack-chat/master/lib/assets/icon256.png"
          wait: true
          member: member
        , (err, response) =>

        # Click handler will enter the chat state for the channel the message was posted in.
        notifier.on 'click', (nc, obj) =>
          @modalPanel.show() # Ensure slack chat is visible
          @setState('chat', obj.member) # Display chat


  # Update user pesence and channel view to accurately display users who are
  # on or off line
  presence_change: (message) =>
    @team.setPresence(message.user, message.presence)
    @channelView.refresh() if @channelView


  ####################################################
  # View Methods
  ####################################################

  # Clear all child elements of the SlackChatView
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
  # Handles current state and state history. Call methods corresponding to state so states
  # can be initialized/handled independently of one another.
  setState: (state) =>
    state = state[0].toUpperCase() + state[1..-1].toLowerCase()
    @stateHistory.push @state if @state # keep track of state history
    @state = state
    @clearRoot() # Clear out all child elements before adding an element to the main view
    @["state#{state}"].apply(this, arguments)

  # Enter a chat conversation state. Use cached chat views when available as it will avoid
  # a call to the api. New messages will be handled via rtm so we should never get behind.
  stateChat: (state, chatTarget) =>
    if @chatHistory[chatTarget.channel.id]
      @slackChatView.addView(@chatHistory[chatTarget.channel.id])
      @chatHistory[chatTarget.channel.id].refresh()
    else
      @chatHistory[chatTarget.channel.id] ||= new ChatView(@, chatTarget)
      @slackChatView.addView(@chatHistory[chatTarget.channel.id])

  # Preload chat messages on startup so entering chat state is a little faster
  preloadChat: (chat) =>
    @chatHistory[chat.id] ||= new ChatView(@, chat) if atom.config.get('slack-chat.preloadChat')

  # Updating the chat view when a message is received. It will ensure the view displays the
  # message correctly.
  updateChat: (message) =>
    console.log "update chat"
    if @chatHistory[message.channel]
      @chatHistory[message.channel].receiveMessage(message)

  # Updating the chat view via channel will scroll to bottom. This is used for the few cases images
  # haven't loaded yet. When they load, they'll call this method which will scroll to the bottom
  # after the new height is calculated.
  updateChatView: (channel) =>
    if @chatHistory[channel]
      @chatHistory[channel].update()

  # Default state where available channels and users are displayed
  stateDefault: =>
    @stateHistory = [] # No need to store previous states when we land at the default
    @channelView.refresh() if @channelView # refreshes event handlers
    @channelView ||= new ConversationView(@, @client)
    @slackChatView.addView(@channelView)

  # Similar to the default channel view state, the upload state lets you choose channels that
  # should receive the selection of text (snippet)
  stateUpload: =>
    @uploadView.refresh() if @uploadView
    @uploadView ||= new FileUploadView(@)
    @slackChatView.addView(@uploadView)

  toggle: =>
    if @modalPanel.isVisible() then @modalPanel.hide() else @modalPanel.show()

