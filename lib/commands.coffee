
module.exports =
class Commands

  constructor: (@stateController, @subscriptions) ->
    # Register slack-chat commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:move-down', => @commands.moveDown()
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:move-up', => @commands.moveUp()
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:open-conversation', => @commands.openConversation()
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:close-conversation', => @commands.closeConversation()
    @subscriptions.add atom.commands.add 'atom-workspace', 'slack-chat:upload-selection', => @commands.uploadSelection()

  # Move channel/member selection down
  moveDown: =>
    @stateController.channelView.nextConversation()

  # Move channel/member selection up
  moveUp: =>
    @stateController.channelView.prevConversation()

  # Enter chat view for a channel
  openConversation: =>
    @stateController.channelView.openConversation()

  # Return to default state (conversation view)
  closeConversation: =>
    @stateController.setState('default')

  # Upload a selection of text
  uploadSelection: =>
    @stateController.modalPanel.show()
    @stateController.setState('upload')
