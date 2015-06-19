
ConversationView = require './conversation-view'
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class FileUploadView extends ScrollView
  @content: (@stateController) ->
    @div id: 'upload', =>
      @div 'Share with:', class: 'share-with'
      @ul id: 'channels', =>
        for channel in @stateController.team.channels
          @li "##{channel.name}", class: 'channel', id: channel.id
      @ul id: 'members', =>
        for member in @stateController.team.membersNotMe()
          @li member.name, class: 'channel', id: member.channel.id

      @div id: 'comment-wrapper', =>
        @label 'Comment', for: 'comment'
        @textarea id: 'comment', class: 'form-control', outlet: @comment
        @button 'Upload', id: 'submit', class: 'btn btn-primary'


  initialize: (@stateController, @client) ->
    @channels = []
    @width(250)
    @eventHandlers()
    super

  eventHandlers: =>
    @.on 'click', '.channel', @selectChannel
    @.on 'click', '#submit', @uploadSelection

  refresh: =>
    @eventHandlers()

  selectChannel: (e) =>
    if e.ctrlKey or e.shiftKey
      @channels.push $(e.target).attr('id')
    else
      $(el).removeClass('selected') for el in $(".selected")
      @channels = [$(e.target).attr('id')]
    $(e.target).addClass('selected')

  uploadSelection: (e) =>
    @stateController.fileManager.uploadSelection(@channels, $("#comment").val())

