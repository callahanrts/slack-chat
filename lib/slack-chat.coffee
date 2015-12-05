
StateController = require './state-controller'
Commands = require './commands'
{CompositeDisposable} = require 'atom'

{$} = require 'atom-space-pen-views'

module.exports = SlackChat =
  config:
    api_key:
      title: "Client ID"
      description: "Slack API client id from https://api.slack.com/applications/new"
      default: 'null'
      type: 'string'
    api_secret:
      title: "Client Secret"
      description: "Slack API client secret from https://api.slack.com/applications/new"
      default: 'null'
      type: 'string'
    api_token:
      title: 'Slack Token'
      description: 'slack-chat should manage this for you (reset to change teams)'
      default: 'null'
      type: 'string'
    notifications:
      title: 'Use system notifications'
      description: 'When this is enabled, system notifications will alert you of received messages.'
      default: true
      type: 'boolean'
    preloadChat:
      title: 'Load conversations on startup'
      description: 'slack-chat will load your conversations on startup instead of when requested'
      default: false
      type: 'boolean'

  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Control slack-chat state and objects passed to each state
    @stateController = new StateController(@subscriptions)

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:toggle', => @toggle()

    # Manage Commands
    @commands = new Commands(@stateController, @subscriptions)

  deactivate: ->
    @subscriptions.dispose()
    @stateController.destroyElements()

  serialize: ->
    #slackChatViewState: @slackChatView.serialize()

  toggle: ->
    console.log 'SlackChat was toggled!'
    @stateController.toggle()

