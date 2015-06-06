# Views
ConversationView = require './conversation-view'
MemberView = require './member-view'
ChannelView = require './channel-view'

{$, ScrollView} = require 'atom-space-pen-views'
SlackClient = require('./slack_client.coffee')
RTMClient = require('./rtm-client')

_ = require 'underscore-plus'


module.exports =
class SlackChatView extends ScrollView
  @content: ->
    @div class: 'slack-wrapper', =>
      @div class: 'slack-header list-inline tab-bar inset-panel', =>
        @div 'Slack Chat', class: 'slack-title', outlet: 'title'
      @div class: 'slack-chat-resizer', =>
        @div class: 'slack-chat-scroller', outlet: 'scroller', =>
          @div class: 'conversation', outlet: 'conversation'
          @div class: 'chat-menu', outlet: 'menu', =>
            @ol
              class: 'slack-chat full-menu list-tree has-collapsable-children focusable-panel'
              tabindex: -1
              outlet: 'list'
        @div class: 'slack-chat-resize-handle', outlet: 'resizeHandle'

  initialize: () ->
    super
    @width(400)

  # Tear down any state and detach
  destroy: ->
    # @detach()


  ############################################################
  # Populate
  ############################################################

  getIMs: =>
    @client.get 'im.list'
    .done (resp) =>
      @ims = resp.ims

  addChannels: (channels) =>
    @client.get 'channels.list'
    .done (resp) =>
      @channels ||= resp.channels
      for c in @channels
        c.channel = c.id
        @list.append new ChannelView(c)

  addPeople: (team) =>
    @client.get 'users.list'
    .done (resp) =>
      @team = []
      for member in resp.members
        channel = _.findWhere(@ims, {user: member.id})
        member.channel = _.findWhere(@ims, {user: member.id}).id if channel
        @team.push member
      @list.append new MemberView(m) for m in @team


  ############################################################
  # Display and focus
  ############################################################
  toggle: ->
    if @isVisible() then @detach() else @show()

  show: ->
    @attach() unless @hasParent()
    @focus()

  attach: =>
    if atom.config.get('slack-chat.show_on_right_side')
      @removeClass('panel-left')
      @addClass('panel-right')
      atom.workspace.addRightPanel(item: @)
    else
      @removeClass('panel-right')
      @addClass('panel-left')
      atom.workspace.addLeftPanel(item: @)

  detach: ->
    @scrollLeftAfterAttach = @scroller.scrollLeft()
    @scrollTopAfterAttach = @scrollTop()
    super
