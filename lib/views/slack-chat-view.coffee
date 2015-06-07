
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class SlackChatView extends ScrollView
  @content: ->
    @div class: 'slack-wrapper', =>
      @div id: 'content', outlet: 'content'

  initialize: (@stateController, @client) ->

  addView: (view) ->
    @content.append view

  clearViews: ->
    @content.empty()


