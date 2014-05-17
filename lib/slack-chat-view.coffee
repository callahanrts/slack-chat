{View} = require 'atom'
$ = require 'jquery'
_ = require 'underscore-plus'

slackTeam = []
channels = []
ims = []

# Callahan
# token = "xoxp-2343778742-2343778744-2343809454-cb6720"

# Shortstack
# token = "xoxp-2268699755-2285215027-2304671872-f10511"

module.exports =
class SlackChatView extends View
  conversationView: null

  @content: ->
    @div class: 'slack-chat'
      
  initialize: (serializeState) ->
    @.on 'click', '.member', (e) =>
      @toggle()
      
      # @sendMessage($(e.toElement).data('im'), "test message")

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
      
  # Displays a list of channels in the side panel. Eventually this should probably be a view class
  # or just find a way to use the @div and @ul functions atom seems to use.
  displayChannels: ->
    html = '<div class = "title">Channels</div>'
    html += '<ul class="channels">'
    for c in channels
      html += "<li class='channel'>##{c.name}</li>"
    html += "</ul>"
    $('.slack-chat').prepend html

  # Displays a list of team members in the side panel. Eventually this should probably be a view class
  # or just find a way to use the @div and @ul functions atom seems to use.    
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

    $.get('https://slack.com/api/chat.postMessage', args).done (data) =>
      console.log data
        
  #################################################################################
  #
  # GET Methods
  # Should probably switch to deferreds or something later
  #################################################################################
  getChannels: ->
    unless channels.length > 0
      $.get 'https://slack.com/api/channels.list', { token: atom.config.get('slack-chat.token') }
       .done (data) =>
          if data.ok is true
            for c in data.channels
              channels.push c
            @displayChannels()

  getTeam: ->
    unless slackTeam.length > 0
      $.get "https://slack.com/api/users.list?", { token: atom.config.get('slack-chat.token') }
        .done (data) =>
          if data.ok is true
            for m in data.members
              slackTeam.push m
            @getIMs()

  getIMs: ->
    unless slackTeam.length > 0 and slackTeam[0].im
      $.get 'https://slack.com/api/im.list', { token: atom.config.get('slack-chat.token') }
       .done (data) =>
          if data.ok is true
            for i in data.ims
              m = _.findWhere(slackTeam, {id: i.user})
              m.im = i if m
            @displayTeamMembers()
