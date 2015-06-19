
module.exports =
class Commands

  constructor: (@stateController) ->

  moveDown: =>
    @stateController.channelView.nextConversation()

  moveUp: =>
    @stateController.channelView.prevConversation()

  openConversation: =>
    @stateController.channelView.openConversation()

  closeConversation: =>
    console.log @stateController
    @stateController.setState('default')

  uploadSelection: =>
    @stateController.modalPanel.show()
    @stateController.setState('upload')
