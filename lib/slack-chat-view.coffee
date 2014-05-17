{View} = require 'atom'
$ = require 'jquery'
_ = require 'underscore-plus'

slackTeam = []
channels = []
ims = []


module.exports =
class SlackChatView extends View
  @content: ->
    @div class: 'slack-chat'
      
  initialize: (serializeState) ->
    @.on 'click', '.member', (e) =>
      console.log $(e.toElement).data('im')

    atom.workspaceView.command "slack-chat:toggle", => 
      @getChannels()
      @getTeam()
      @getIMs()
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
        
  getChannels: ->
    unless channels.length > 0
      $.get 'https://slack.com/api/channels.list', { token: 'xoxp-2268699755-2285215027-2304671872-f10511' }
       .done (data) =>
          if data.ok is true
            for c in data.channels
              channels.push c
            @displayChannels()

  getTeam: ->
    unless slackTeam.length > 0
      $.ajax
        async: false
        type: 'GET'
        url:  'https://slack.com/api/users.list?token=xoxp-2268699755-2285215027-2304671872-f10511'
        success: (data) =>
          if data.ok is true
            for m in data.members
              slackTeam.push m

  getIMs: ->
    unless slackTeam.length > 0 and slackTeam[0].im
      $.get 'https://slack.com/api/im.list', { token: 'xoxp-2268699755-2285215027-2304671872-f10511' }
       .done (data) =>
          if data.ok is true
            for i in data.ims
              m = _.findWhere(slackTeam, {id: i.user})
              m.im = i if m
            @displayTeamMembers()
