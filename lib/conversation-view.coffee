{View} = require 'atom'
$ = require 'jquery'

module.exports =
  class ConversationView extends View
    @content: ->
      @div class: 'slack-chat', =>
        @div '<', class: 'back'

    initialize: (callback) ->
      @.on 'click', '.back', (e) =>
        @toggle()
        callback()

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      @detach()

    displayMember: ->
      console.log @member

    toggle: (@member) ->
      if @hasParent()
        @detach()
      else
        @displayMember()
        atom.workspaceView.appendToRight(this)