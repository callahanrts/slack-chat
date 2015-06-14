
ChatMessageView = require './chat-message-view'
{$, ScrollView} = require 'atom-space-pen-views'
marked = require 'marked'
renderer = new marked.Renderer();
highlight = require 'highlight.js'

marked.setOptions
  renderer: renderer
  highlight: (code) ->
    console.log code
    return highlight.highlightAuto(code).value

module.exports =
class ChatLogView extends ScrollView
  root = @
  @content: (@stateController, @messages) ->
    @div class: 'messages', =>
      @div class: 'list', outlet: 'messageViews'

  initialize: (@stateController, @messages) ->
    super
    @messageViews.append(@messageElement(message)) for message in @messages

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
            <span class='ts'>#{@getTime(message.ts)}</span>
          </td>
        </tr>
        <tr>
          <td></td>
          <td>
            <div class='text'>#{marked(message.text)}</div>
          </td>
        </tr>
      <table>
    </div>
    """

  receiveMessage: (message) =>
    console.log 'received message', message
    @messageViews.append(@messageElement(message))


