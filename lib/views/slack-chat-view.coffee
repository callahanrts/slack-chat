
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class SlackChatView extends ScrollView
  @content: ->
    @div class: 'slack-wrapper', =>
      @div id: 'content', outlet: 'content'

  initialize: (@stateController, @client) ->

  # Add a view to the slack-wrapper
  addView: (view) ->
    @content.append view

  # Clear out all views that might be attached to the slack-wrapper
  clearViews: ->
    @content.empty()


