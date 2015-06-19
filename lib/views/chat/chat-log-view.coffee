
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
    min = if min < 10 then "0#{min}" else min
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
    <div class='message native-key-bindings #{message.subtype}'>
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
            <div class='text'>#{@parseMessage(message)}</div>
          </td>
        </tr>
      <table>
    </div>
    """

  file_share: (message) =>
    file = message.file
    console.log file
    dl = "#{file.name}<a href='#{file.url_download}'><span class='download'></span></a>"
    msg = switch
      when file.mimetype.match(/text/)? then @fileText(file)
      when file.mimetype.match(/image/g)? then @fileImage(file)
      else ""
    msg.concat @fileComments(file)
    "#{dl}<br>#{msg}"

  fileComments: (file) =>
    if file.initial_comment
      """
      <div id='#{file.id}_comments' class='file comment'>
        <div class="file_comment">
          <div class="text">
            <p>#{file.initial_comment.comment}</p>
          </div>
        </div>
      </div>
      """
    else
      ""

  fileImage: (file) =>
    """
    <div class='file'>
      <a href='#{file.url}'><img src='#{file.url}' class='image' /></a>
    </div>
    """

  fileText: (file) =>
    marked("""<span class='file'>
      ```
      #{file.preview}
      ```
    </file>""")

  file_comment: (message) =>
    comment = message.comment
    user = @stateController.team.memberWithId(comment.user)
    $("##{message.file.id}_comments", @messageViews).append("""
      <div class="file_comment">
      <span class='name' >#{user.name}</span>
      <span class='ts' >#{@getTime(comment.timestamp)}</span>
      <div class='text'>#{marked(comment.comment)}</div>
      </div>
      """)

  parseMessage: (message) =>
    console.log message.subtype
    switch message.subtype
      when 'file_comment' then @file_comment(message)
      when 'file_share' then @file_share(message)
      else @message(message)

  message: (message) =>
    text = message.text
    message = marked(text)
    message = @stateController.team.parseCustomEmoji(text)
    message = emoji(message, "https://raw.githubusercontent.com/HenrikJoreteg/emoji-images/master/pngs/")
    message

  receiveMessage: (message) =>
    @addMessage(message)
    unless message.user is @stateController.client.me.id
      $(".message", @messageViews).last().addClass("new #{'slack-mark' if $(".new", @messageViews).length is 0}")


