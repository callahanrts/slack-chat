
ChatMessageView = require './chat-message-view'
{$, ScrollView} = require 'atom-space-pen-views'
marked = require 'marked'
renderer = new marked.Renderer()
imagesLoaded = require 'imagesloaded'
highlight = require 'highlight.js'
emoji = require 'emoji-images'
og = require 'open-graph'

# Set options for the markdown parser
marked.setOptions
  renderer: renderer
  highlight: (code) ->
    return highlight.highlightAuto(code).value

module.exports =
class ChatLogView extends ScrollView
  root = @
  @content: (@stateController, @messages) ->
    @div class: 'messages native-key-bindings', tabindex: -1, =>
      @div class: 'list', outlet: 'messageViews'

  initialize: (@stateController, @messages, @chat) ->
    super
    @addMessage(message) for message in @messages

  # Add a message to the chat log when a new message is received
  addMessage: (message) =>
    @messageViews.append(@messageElement(message))

  # Parse the time a message was sent from epoch to human readable
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

  # HTML Representation of a message. This will parse the message so the author, text, open graph, emoji
  # etc can all be displayed in a pleasing manner
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


  # Called when the file_share message subtype is encountered. It parses and displays the file
  file_share: (message) =>
    file = message.file

    # Create a download link for the file (cloud download icon)
    dl = "#{file.name}<a href='#{file.url_download}'><span class='download'></span></a>"

    # Parse the text or image file received
    msg = switch
      when file.mimetype.match(/text/)? then @fileText(file)
      when file.mimetype.match(/image/g)? then @fileImage(file)
      else ""

    # Make sure file comments are available with the file
    msg.concat @fileComments(file)
    "#{dl}<br>#{msg}"

  # Comments about a file.
  fileComments: (file) =>
    # Only display this file_comments div if the comment is the first comment
    # shipped with the file upload
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

  # Create an image element out of the image file upload
  fileImage: (file) =>
    """
    <div class='file'>
      <a href='#{file.url}'><img src='#{file.url}' class='image' /></a>
    </div>
    """

  # Text files are usually snippets and should be inserted into a code block
  # and parsed with markdown
  fileText: (file) =>
    marked("""<span class='file'>
      ```
      #{file.preview}
      ```
    </file>""")

  # When the file_comment suptype is received, a message is not actually added to
  # to the log, but to the corresponding comments section of the file upload
  file_comment: (message) =>
    comment = message.comment
    user = @stateController.team.memberWithId(comment.user)

    # Append file_comment to the file that was previously parsed
    $("##{message.file.id}_comments", @messageViews).append("""
      <div class="file_comment">
      <span class='name' >#{user.name}</span>
      <span class='ts' >#{@getTime(comment.timestamp)}</span>
      <div class='text'>#{marked(comment.comment)}</div>
      </div>
      """)

  # Simple url parser to retrieve params from links (youtube video id)
  getURLParam: (url, param) ->
    url?.split("#{param}=")?[1]?.split("&")?[0]

  # Parse links and decide what to do with them.
  parseLinks: (message) =>
    urls = message.replace(/<[^>]*>/g, "") # Break free links that are stuck inside of anchor tags

    # Find all urls in the message text and create an array out of them
    urls = urls.match(/(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})/g)
    data = ''
    if urls
      for url in urls
        # For each url, decide whether to display an image, video, or open graph data based on the
        # source of the url
        data = switch
          when (/\.(gif|jpg|jpeg|tiff|png)$/i).test(url) then @fileImage({url: url})
          when (/youtube\.com.*$/i).test(url) then @youtubeElement(url)
          when (/vimeo\.com.*$/i).test(url) then @vimeoElement(url)
          else @openGraphElement(url)
    message.concat data

  # Use different parsing methods based on message subtype. Default to plaintext message
  parseMessage: (message) =>
    switch message.subtype
      when 'file_comment' then @file_comment(message)
      when 'file_share' then @file_share(message)
      else @message(message)

  # Parse all the emoji, markdown, and links you might find in a typical message
  message: (message) =>
    return '' unless message?.text?
    text = message.text
    text = marked(text)
    text = text.replace(/(?:\r\n|\r|\n)/g, '<br />')
    text = @parseLinks(text)
    text = @stateController.team.parseCustomEmoji(text)
    text = emoji(text, "https://raw.githubusercontent.com/HenrikJoreteg/emoji-images/master/pngs/")
    text

  # Create elements for a pleasing open graph message view
  metaElements: (url, meta) =>
    elements = []
    elements.push("<img src='#{meta.image.url}' class='og_image' />") if meta?.image?.url?
    elements.push("<a href='#{url}'><div class='og_title'>#{meta.title}</div></a>") if meta?.title?
    elements.push("<div class='og_description'>#{meta.description}</div>") if meta?.description?
    elements.join('')

  # Retrieve open graph data and update the message contents if necessary
  openGraphData: (url, id) =>
    og url, (err, meta) =>
      og_elements = @metaElements(url, meta)
      $("##{id}").html(og_elements) unless err
      $("##{id}").remove() unless og_elements
      imagesLoaded $("##{id}"), =>
        @stateController.updateChatView(@chat.channel.id)

  # Temporary open graph element. It will be deleted if nothing is found or filled
  # with open graph elements if they can be retrieved
  openGraphElement: (url) =>
    id = Date.now()
    @openGraphData(url, id)
    "<div id='#{id}' class='og_data'></div>"

  # Receive a message from the rtm client
  receiveMessage: (message) =>
    # Add message to the logs
    @addMessage(message)

    unless message.user is @stateController.client.me.id
      # Mark the last message as unread. It will set a horizontal bar to indicate unread messages
      $(".message", @messageViews).last().addClass("new #{'slack-mark' if $(".new", @messageViews).length is 0}")

  # Parse and embed a vimeo video url
  vimeoElement: (url) =>
    url_parts = url.split("/")
    id = url_parts[url_parts.length - 1]
    """
    <div class='video-wrapper'>
      <iframe src="https://player.vimeo.com/video/#{id}" frameborder="0"></iframe>
    </div>
    """

  # Parse and embed a youtube video url
  youtubeElement: (url) =>
    id = @getURLParam(url, 'v')
    """
    <div class='video-wrapper'>
      <iframe width='560' height='315' src='https://www.youtube.com/embed/#{id}' frameborder='0'></iframe>
    </div>
    """
