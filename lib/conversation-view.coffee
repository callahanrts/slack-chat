{View} = require 'atom'
$ = require 'jquery'

module.exports =
class ConversationView extends View
  @content: ->
    
  initialize: (serializeState) ->

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.appendToRight(this)