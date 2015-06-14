
ChatMessageView = require './chat-message-view'
{$, ScrollView} = require 'atom-space-pen-views'
marked = require 'marked'
renderer = new marked.Renderer()
highlight = require 'highlight.js'
emoji = require 'emoji-images'

marked.setOptions
  renderer: renderer
  highlight: (code) ->
    return highlight.highlightAuto(code).value

module.exports =
class ChatLogView extends ScrollView
  root = @
  @content: (@stateController, @messages) ->
    @div class: 'messages', =>
      @div class: 'list', outlet: 'messageViews'

  initialize: (@stateController, @messages) ->
    super
    @addMessage(message) for message in @messages

  addMessage: (message) =>
    @messageViews.append(@messageElement(message))

  getTime: (timestamp) ->
    a = new Date(timestamp * 1000)
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    month = months[a.getMonth()]
    date = a.getDate()
    hour = a.getHours()
    min = a.getMinutes()
    year = a.getFullYear()
    if hour > 12
      hour = hour - 12
      t = " pm"
    else
      t = " am"
    "#{month} #{date}#{if year < (new Date()).getFullYear() then ", #{year}" else ''} #{hour}:#{min} #{t}"

  messageElement: (message) =>
    author = @stateController.team.memberWithId(message.user) || @stateController.team.unknownUser(message)
    image = author.image
    name = author.name
    """
    <div class='message native-key-bindings'>
      <table>
        <tr>
          <td>
            <img class='image' src=#{image} />
          </td>
          <td>
            <span class='name'>#{name}</span>
            <span class='ts'>#{@getTime(message.ts)}</span>
          </td>
        </tr>
        <tr>
          <td></td>
          <td>
            <div class='text'>#{@parseMessage(message.text)}</div>
          </td>
        </tr>
      <table>
    </div>
    """

  parseMessage: (text) =>
    message = marked(text)
    message = @stateController.team.parseCustomEmoji(text)
    message = emoji(message, "https://raw.githubusercontent.com/HenrikJoreteg/emoji-images/master/pngs/")
    message

  receiveMessage: (message) =>
    @addMessage(message)
    unless message.user is @stateController.client.me.id
      $(".message", @messageViews).last().addClass("new #{'slack-mark' if $(".new", @messageViews).length is 0}")


