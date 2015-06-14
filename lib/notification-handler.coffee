
NotificationView = require './views/notification-view'

{$} = require 'atom-space-pen-views'

module.exports =
class NotificationHandler

  constructor: (@stateController) ->
    @notifications = []
    @view = new NotificationView(@stateController, 'message')
    @modalNotification = atom.workspace.addRightPanel(item: @view, visible: false, className: 'slack-notification')
    @addEvent('test')

  addEvent: (message) =>
  #  @notifications << message
  #  @alertUser()

  handleMessage: (message) =>
    $("##{message.channel}").addClass("unread")
    @stateController.updateChat(message)

  alertUser: =>
    @modalNotification.show()
    setTimeout =>
      @modalNotification.hide()
    , 3000

  readNotification: (message) ->
    @notifications.remove(message)


