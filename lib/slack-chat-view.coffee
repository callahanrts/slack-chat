ConversationView = require './conversation-view'
SlackAPI = require './slack-api'
{$, ScrollView} = require 'atom'
_ = require 'underscore-plus'

slackTeam = []
module.exports =
  class SlackChatView extends ScrollView
    conversationView: null

    @content: (params) ->
      # @div class: 'slack-chat-resizer', 
      #'data-show-on-right-side': atom.config.get('slack-chat.show_on_right_side'), =>
      @div class: 'slack-chat-resizer', =>
        @div class: 'slack-chat-scroller', outlet: 'scroller', =>
          # @div class: 'list-inline tab-bar inset-panel', =>
            # @div 'Slack Chat', class: 'slack-title'
          @ol 
            class: 'slack-chat full-menu list-tree has-collapsable-children focusable-panel'
            tabindex: -1
            outlet: 'list'
        @div class: 'slack-chat-resize-handle', outlet: 'resizeHandle'
      #   
      # slackTeam = params.slackTeam
      # @div class: 'slack-chat', =>
      #   @div class: 'list-inline tab-bar inset-panel', =>
      #     @div 'Slack Chat', class: 'slack-title'
      # 
      #   @div class: 'tree-view-scroller', =>
      #     @div 'Channels', class: 'title'
      #     @ol class: 'tree-view full-menu list-tree focusable-panel', =>
      #       for c in params.channels
      #         @li class: 'file entry list-item', =>
      #           @span "##{c.name}", class: "name icon icon-book" 
      # 
      #     @div 'Users', class: 'title'
      #     @ol class: 'users', =>
      #       for u in params.slackTeam
      #         @li "#{u.name}", class: 'member', 'data-id': u.id, click: 'openConversation'
  
    initialize: (serializeState) ->
      @width(400)
      @on 'mousedown', '.slack-chat-resize-handle', (e) => @resizeStarted(e)
      # @sendMessage($(e.toElement).data('im'), "test message")

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      @detach()

    # toggle: ->
    #   if @hasParent()
    #     @detach()
    #   else
    #     atom.workspaceView.appendToRight(this)
    openConversation: (e, el) ->
      member = _.findWhere(slackTeam, { id: $(el).data('id') })
      @slack = new SlackAPI()
      @conversationView = new ConversationView(member, @slack.messages(member.im.id), => @toggle())
      @conversationView.toggle()
      @toggle()
      
    ############################################################
    # Display and focus
    #
    ############################################################
      
    toggle: ->
      if @isVisible()
        @detach()
      else
        @show()

    show: ->
      @attach() unless @hasParent()
      @focus()
    
    attach: ->
      if atom.config.get('slack-chat.show_on_right_side')
        @removeClass('panel-left')
        @addClass('panel-right')
        atom.workspaceView.appendToRight(this)
      else
        @removeClass('panel-right')
        @addClass('panel-left')
        atom.workspaceView.appendToLeft(this)

    detach: ->
      @scrollLeftAfterAttach = @scroller.scrollLeft()
      @scrollTopAfterAttach = @scrollTop()

      super
      atom.workspaceView.focus()

    focus: ->
      @list.focus()

    unfocus: ->
      atom.workspaceView.focus()

    hasFocus: ->
      @list.is(':focus') or document.activeElement is @list[0]

    toggleFocus: ->
      if @hasFocus()
        @unfocus()
      else
        @show()


    ######################################################
    # Resize Code
    #
    ######################################################
    resizeStarted: =>
      $(document.body).on('mousemove', @resizeTreeView)
      $(document.body).on('mouseup', @resizeStopped)

    resizeStopped: =>
      $(document.body).off('mousemove', @resizeTreeView)
      $(document.body).off('mouseup', @resizeStopped)

    resizeTreeView: ({pageX}) =>
      if atom.config.get('slack-chat.show_on_right_side')
        width = $(document.body).width() - pageX
      else
        width = pageX
      @width(width)