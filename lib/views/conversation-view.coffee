
ChannelView = require './conversations/channel-view'
MemberView = require './conversations/member-view'
{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
class ConversationView extends ScrollView
  @content: ->
    @div id: 'conversations', =>
      @div class: 'title', outlet: 'title'
      @ul id: 'channels', outlet: 'channelElements'
      @ul id: 'members', outlet: 'memberElements'

  initialize: (@stateController, @client) ->
    super
    @currentConversation = null
    @channelViews ||= []
    @memberViews ||= []
    @getChannels()
    @getMembers()
    @getTeamInfo()

  # Retrieve channels from the team object and create channel views for them. These Views
  # are then added to the conversation view (self)
  getChannels: () =>
    @channels = @stateController.team.channels
    for channel in @channels
      @channelViews.push new ChannelView(@stateController, channel)
      @stateController.preloadChat(channel)
    @channelElements.append(view) for view in @channelViews

  # Retrieve members from the team object and create member views for them. These Views
  # are then added to the conversation view (self)
  getMembers: (callback) =>
    @members = @stateController.team.membersNotMe()
    for member in @members
      if member?.channel?.id?
        @memberViews.push new MemberView(@stateController, member)
        @stateController.preloadChat(member)
    @memberElements.append(view) for view in @memberViews

  # Display the team name and image at the top of the channel view
  getTeamInfo: =>
    @client.get 'team.info', {}, (err, resp) =>
      @title.append(@titleElement(resp.body.team))

  # Used by keybindings to navigate to the next selection
  nextConversation: =>
    convos = $('li', '#conversations')
    if @currentConversation?
      index = convos.index(@currentConversation)
      @setCurrentConversation($(convos[index + 1])) if index < convos.length - 1
    else
      @setCurrentConversation $('li', '#conversations').first()

  # Used by keybindings to navigate to the previous selection
  prevConversation: =>
    convos = $('li', '#conversations')
    if @currentConversation?
      index = convos.index(@currentConversation)
      @setCurrentConversation($(convos[index - 1])) if index > 0
    else
      @setCurrentConversation convos.last()

  # Enter the chat state for the selected conversation. Using the currently selected
  # conversation here would be ideal, but some users like the mouse.
  openConversation: =>
    @convos = @channelViews.concat(@memberViews) # Combine channel and member views
    index = $('li', '#conversations').index @currentConversation # Get an index for the selected view
    @currentConversation.removeClass('unread') # Mark as read when entering
    @convos[index]?.showConversation() # Show the conversation for the selected channel/member

  # Set the current conversation as the user navigates up or down conversations with the keyboard
  setCurrentConversation: ($convo) =>
    $(el).removeClass('selected') for el in $('li', '#conversations')
    $convo.addClass('selected')
    @currentConversation = $convo

  # Refresh event handlers and view attributes for member and channel views
  refresh: ->
    view.refresh() for view in @memberViews
    view.eventHandlers() for view in @channelViews

  # HTML representation of team data at the top of the view
  titleElement: (team) ->
    "<img id='teamIcon' src='#{team.icon.image_44}' /><h1>#{team.name}</h1>"
