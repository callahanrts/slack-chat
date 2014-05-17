{View} = require 'atom'
$ = require 'jquery'
_ = require 'underscore-plus'

slackTeam = []
channels = []
ims = []
username = '(AT) cody'

# Callahan
token = "xoxp-2343778742-2343778744-2343809454-cb6720"

# Shortstack
# token = "xoxp-2268699755-2285215027-2304671872-f10511"

module.exports =
class SlackChatView extends View
  @content: ->
    @div class: 'slack-chat'
      
  initialize: (serializeState) ->
    @.on 'click', '.member', (e) =>
      console.log $(e.toElement).data('im')
      @sendMessage($(e.toElement).data('im'), "test message")

    atom.workspaceView.command "slack-chat:toggle", => 
      @getChannels()
      @getTeam()
      @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.appendToRight(this)
      
  displayChannels: ->
    html = '<div class = "title">Channels</div>'
    html += '<ul class="channels">'
    for c in channels
      html += "<li class='channel'>##{c.name}</li>"
    html += "</ul>"
    $('.slack-chat').prepend html
    
  displayTeamMembers: ->
    html = '<div class ="title">Users</div>'
    html += '<ul class="users">'
    for m in slackTeam
      html += "<li class = 'member' data-im='#{m.im.id if m.im}'>#{m.name}</li>"
    html += '</ul>'
    $('.slack-chat').append html
    

  sendMessage: (im, message) ->
    regex = /:.{1,}:/
    icon = atom.config.get('slack-chat.icon_emoji_or_image')
    args = {
      token: atom.config.get('slack-chat.token')
      channel: im
      text: message
      username: atom.config.get('slack-chat.username')
    }
    if regex.test(icon)
      args.icon_emoji = icon
    else
      args.icon_image = icon

    console.log args
    $.get('https://slack.com/api/chat.postMessage', args).done (data) =>
      console.log data
        
  #################################################################################
  #
  # GET Methods
  #
  #################################################################################
  getChannels: ->
    unless channels.length > 0
      $.get 'https://slack.com/api/channels.list', { token: token }
       .done (data) =>
          if data.ok is true
            for c in data.channels
              channels.push c
            @displayChannels()

  getTeam: ->
    unless slackTeam.length > 0
      $.get "https://slack.com/api/users.list?", { token: token }
        .done (data) =>
          if data.ok is true
            for m in data.members
              slackTeam.push m
            @getIMs()

  getIMs: ->
    unless slackTeam.length > 0 and slackTeam[0].im
      $.get 'https://slack.com/api/im.list', { token: token }
       .done (data) =>
          if data.ok is true
            for i in data.ims
              m = _.findWhere(slackTeam, {id: i.user})
              m.im = i if m
            @displayTeamMembers()
