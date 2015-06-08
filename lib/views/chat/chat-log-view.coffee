
ChatMessageView = require './chat-message-view'
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class ChatLogView extends ScrollView
  @content: (@stateController, @messages) ->
    @div id: 'messages', outlet: 'messageViews', =>
      # NOTE: Use this for parsing markdown
      # https://github.com/chjj/marked
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

  messageElement: (message) =>
    author = @stateController.team.members[message.user]
    image = @stateController.team.memberImage(author, message)
    name = @stateController.team.memberName(author, message)
    """
    <div class='message native-key-bindings'>
      <table>
        <tr>
          <td>
            <img class='image' src=#{image} />
          </td>
          <td>
            <span class='name'>#{name}</span>
            <span class='ts'>#{message.ts}</span>
          </td>
        </tr>
        <tr>
          <td></td>
          <td>
            <div class='text'>#{message.text}</div>
          </td>
        </tr>
      <table>
    </div>
    """

  receiveMessage: (message) =>
    $("#messages").append(@messageElement(message))


