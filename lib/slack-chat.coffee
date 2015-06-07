
StateController = require './state-controller'
{CompositeDisposable} = require 'atom'

module.exports = SlackChat =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:toggle', => @toggle()

    # Control slack-chat state and objects passed to each state
    @stateController = new StateController()

  deactivate: ->
    @subscriptions.dispose()
    @stateController.destroyElements()

  serialize: ->
    #slackChatViewState: @slackChatView.serialize()

  toggle: ->
    console.log 'SlackChat was toggled!'
    @stateController.toggle()

