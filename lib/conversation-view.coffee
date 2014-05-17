{View} = require 'atom'
$ = require 'jquery'

module.exports =
  class ConversationView extends View
    @content: (member) ->
      @div class: 'slack-chat', =>
        @div '<', class: 'back', click: 'toggle'
        @div "#{member.name}", class: 'title'

    initialize: (member, @callback) ->

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      @detach()

    toggle: ->
      if @hasParent()
        @detach()
        @callback()
      else
        atom.workspaceView.appendToRight(this)