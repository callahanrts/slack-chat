{View} = require 'atom'

module.exports =
class SlackChatView extends View
  @content: ->
    @div class: 'slack-chat', => 
      @div "The SlackChat package is Alive! It's ALIVE!"

  initialize: (serializeState) ->
    atom.workspaceView.command "slack-chat:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "SlackChatView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.appendToRight(this)