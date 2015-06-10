

{$, View} = require 'atom-space-pen-views'

module.exports =
class NotificationView extends View
  @content: (@stateController, @message) ->
    @div 'test', class: 'notification'

  initialize: (@stateController, @message) ->

