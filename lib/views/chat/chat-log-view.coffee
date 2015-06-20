
ChatMessageView = require './chat-message-view'
{$, ScrollView} = require 'atom-space-pen-views'
marked = require 'marked'
renderer = new marked.Renderer()
imagesLoaded = require 'imagesloaded'
highlight = require 'highlight.js'
emoji = require 'emoji-images'
og = require 'open-graph'

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

  initialize: (@stateController, @messages, @chat) ->
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

  getLink: (message, url) ->
    message.replace(url, "<a href='#{url}'>#{url}</a>")

  getURLParam: (url, param) ->
    url.split("#{param}=")[1].split("&")[0]

  parseLinks: (message) =>
    message = message.replace(/<[^>]*>/g, "")
    urls = message.match(/(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})/g)
    data = ''
    if urls
      for url in urls
        message = @getLink(message, url)
        data = switch
          when (/\.(gif|jpg|jpeg|tiff|png)$/i).test(url) then @fileImage({url: url})
          when (/youtube\.com.*$/i).test(url) then @youtubeElement(url)
          when (/vimeo\.com.*$/i).test(url) then @vimeoElement(url)
          else @openGraphElement(url)
    message.concat data

  parseMessage: (message) =>
    switch message.subtype
      when 'file_comment' then @file_comment(message)
      when 'file_share' then @file_share(message)
      else @message(message)

  message: (message) =>
    text = message.text
    message = marked(text)
    message = @parseLinks(message)
    message = @stateController.team.parseCustomEmoji(message)
    message = emoji(message, "https://raw.githubusercontent.com/HenrikJoreteg/emoji-images/master/pngs/")
    message

  metaElements: (url, meta) =>
    elements = []
    elements.push("<img src='#{meta.image.url}' class='og_image' />") if meta?.image?.url?
    elements.push("<a href='#{url}'><div class='og_title'>#{meta.title}</div></a>") if meta?.title?
    elements.push("<div class='og_description'>#{meta.description}</div>") if meta?.description?
    elements.join('')

  openGraphData: (url, id) =>
    og url, (err, meta) =>
      og_elements = @metaElements(url, meta)
      $("##{id}").html(og_elements) unless err
      $("##{id}").remove() unless og_elements
      imagesLoaded $("##{id}"), =>
        @stateController.updateChatView(@chat.channel.id)

  openGraphElement: (url) =>
    id = Date.now()
    @openGraphData(url, id)
    "<div id='#{id}' class='og_data'></div>"

  receiveMessage: (message) =>
    @addMessage(message)
    unless message.user is @stateController.client.me.id
      $(".message", @messageViews).last().addClass("new #{'slack-mark' if $(".new", @messageViews).length is 0}")

  vimeoElement: (url) =>
    url_parts = url.split("/")
    id = url_parts[url_parts.length - 1]
    """
    <div class='video-wrapper'>
      <iframe src="https://player.vimeo.com/video/#{id}" frameborder="0"></iframe>
    </div>
    """

  youtubeElement: (url) =>
    id = @getURLParam(url, 'v')
    """
    <div class='video-wrapper'>
      <iframe width='560' height='315' src='https://www.youtube.com/embed/#{id}' frameborder='0'></iframe>
    </div>
    """
