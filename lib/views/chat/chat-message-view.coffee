
{$, View} = require 'atom-space-pen-views'

module.exports =
class ChatMessageView extends View
  @content: (@author, @message) ->
    image = if @author? then @author.profile.image_32 else @message.icons.image_64
    name = if @author? then @author.name else @message.username
    @div class: 'message native-key-bindings', =>
      @table =>
        @tr =>
          @td =>
            @img class: 'image', src: image
          @td =>
            @span class: 'name', name
            @span class: 'ts', @message.ts
        @tr =>
          @td ''
          @td =>
            @div @message.text, class: 'text'


  initialize: (@stateController, @chat, @message) ->
