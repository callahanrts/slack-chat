
ChatMessageView = require './chat-message-view'
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class ChatLogView extends ScrollView
  @content: (@stateController, @messages) ->
    @div id: 'messages', outlet: 'messageViews', =>
      for message in @messages
        author = @stateController.team.members[message.user]
        image = @stateController.team.memberImage(author, message)
        name = @stateController.team.memberName(author, message)

        @div class: 'message native-key-bindings', =>
          @table =>
            @tr =>
              @td =>
                @img class: 'image', src: image
              @td =>
                @span class: 'name', name
                @span class: 'ts', message.ts
            @tr =>
              @td ''
              @td =>
                @div message.text, class: 'text'


  initialize: (@stateController, @messages) ->
    super

