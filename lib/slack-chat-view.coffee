{View} = require 'atom'
$ = require 'jquery'

slackTeam = []
channels = []

_div = null

module.exports =
class SlackChatView extends View
  @content: ->
    _div = @div
    @div class: 'slack-chat', =>
      
  initialize: (serializeState) ->
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
      
  getChannels: ->
    unless channels.length > 0
      $.get 'https://slack.com/api/channels.list?token=xoxp-2268699755-2285215027-2304671872-f10511'
       .done (data) =>
          if data.ok is true
            for c in data.channels
              channels.push c
            @displayChannels()

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
      console.log m, m.name
      html += "<li class ='member'>#{m.name}</li>"
    html += '</ul>'
    $('.slack-chat').append html
        
  getTeam: ->
    unless slackTeam.length > 0
      $.get 'https://slack.com/api/users.list?token=xoxp-2268699755-2285215027-2304671872-f10511'
       .done (data) =>
          if data.ok is true
            for m in data.members
              slackTeam.push m
          @displayTeamMembers()
      
class SlackMember
  constructor: (@data) ->
    
  sendMessage: (message) ->
    console.log @data.real_name, message