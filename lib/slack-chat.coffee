
StateController = require './state-controller'
Commands = require './commands'
{CompositeDisposable} = require 'atom'

{$} = require 'atom-space-pen-views'

module.exports = SlackChat =
  config:
    token:
      title: 'Slack Token'
      description: 'slack-chat should manage this for you (reset to change teams)'
      default: 'null'
      type: 'string'
    preloadChat:
      title: 'Load conversations on startup'
      description: 'slack-chat will load your conversations on startup instead of when requested'
      default: false
      type: 'boolean'
    notifications:
      title: 'Use system notifications'
      description: 'When this is enabled, system notifications will alert you of received messages.'
      default: true
      type: 'boolean'

  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Control slack-chat state and objects passed to each state
    @stateController = new StateController(@subscriptions)
    # Manage Commands
    @commands = new Commands(@stateController)

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:toggle', => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:toggle-mode', => @toggleMode()

    # Slack chat mode commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:move-down', => @commands.moveDown()
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:move-up', => @commands.moveUp()
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:open-conversation', => @commands.openConversation()
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:close-conversation', => @commands.closeConversation()

  deactivate: ->
    @subscriptions.dispose()
    @stateController.destroyElements()

  serialize: ->
    #slackChatViewState: @slackChatView.serialize()

  toggle: ->
    console.log 'SlackChat was toggled!'
    @stateController.toggle()

  toggleMode: ->
    $("atom-workspace").toggleClass('slack-chat')

