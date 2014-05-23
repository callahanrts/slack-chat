# Views
ConversationView = require './conversation-view'
MemberView = require './member-view'
ChannelView = require './channel-view'

SlackAPI = require './slack-api'
{$, ScrollView} = require 'atom'
_ = require 'underscore-plus'

module.exports =
  class SlackChatView extends ScrollView
    conversationView: null

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
      @slack = new SlackAPI()
      @slack.addMessageSubscription(@newMessage)
      @prevConversations = []
      @nextConversations = []
      @width(400)
      @addChannels()
      @addPeople()
      @on 'mousedown', '.slack-chat-resize-handle', (e) => @resizeStarted(e)
      @on 'click', '.entry', (e) => @entryClicked(e)

      @command 'core:move-up', => @moveUp()
      @command 'core:move-down', => @moveDown()

      @command 'slack-chat:jump-to-previous-conversation', => @previousConversation()
      @command 'slack-chat:jump-to-next-conversation', => @nextConversation()
      @command 'core:cancel', => @closeConversation()
      # @command 'slack-chat:toggle-focus', => @toggleFocus()
      @command 'slack-chat:open-conversation', => @openConversation(@selectedEntry())
      @command 'slack-chat:close-conversation', => @backToMenu()

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      @detach()
      
    newMessage: (messages) ->
      $('.entry', '.slack-chat').each (index, element) ->
        view = $(element).view()
        model = view.member if view instanceof MemberView
        model = view.channel if view instanceof ChannelView
        message = _.findWhere messages, {channel_id: model.id} if model
        if model and message
          view.newMessages.html message.count unless view instanceof ChannelView
          view.newMessages.show()

    openConversation: (view) ->
      view.newMessages.hide()
      room = view.member
      unless room
        room = view.channel
        room.im = {id: room.id, channel: true}
      @currentConversation = new ConversationView(room, @)
      @prevConversations.push @currentConversation
      @menu.hide()
      @conversation.show()
      @conversation.html @currentConversation
      @currentConversation.focus()
      
    closeConversation: () ->
      @title.text 'Slack Chat'
      @currentConversation = null
      @conversation.hide()
      @menu.show()
      @focus()
      
    nextConversation: () ->
      # if @nextConversations.length > 0
      #   c = @nextConversations.pop()
      #   c.load()
      #   @conversation.html c
      #   c.focus()
      #   @prevConversations.push c

    previousConversation: () ->
      if @prevConversations.length > 0
        @menu.hide()
        @conversation.show()
        c = @prevConversations.pop()
        c = @prevConversations.pop() if c is @currentConversation
        c.load()
        @conversation.html c
        c.focus()
        @nextConversations.push c

    ############################################################
    # Selection
    #
    ############################################################
    selectedEntry: ->
      @list.find('.selected')?.view()

    selectEntry: (entry) ->
      entry = entry?.view()
      return false unless entry?

      @deselect()
      entry.addClass('selected')

    deselect: ->
      @list.find('.selected').removeClass('selected')
      
    entryClicked: (e, el) ->
      entry = $(e.currentTarget).view()
      @selectEntry(entry)
      @openConversation(entry) if entry instanceof MemberView
      false
      
    moveDown: ->
      selectedEntry = @selectedEntry()
      if selectedEntry
        @selectEntry(selectedEntry.next('.entry'))
      else
        @selectEntry(@list.find('.entry').first())
      @scrollToEntry(@selectedEntry())

    moveUp: ->
      selectedEntry = @selectedEntry()
      if selectedEntry
        @selectEntry(selectedEntry.prev('.entry'))
      else
        @selectEntry(@list.find('.entry').last())
      @scrollToEntry(@selectedEntry())

      
    ############################################################
    # Populate
    #
    ############################################################
    addChannels: ->
      @channels ||= @slack.channels()
      for c in @channels
        @list.append new ChannelView(c)

    addPeople: ->
      @team ||= @slack.team()
      for m in @slack.team()
        @list.append new MemberView(m)

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
      @currentConversation.focus() if @currentConversation

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
              
    ######################################################
    # Scroll Code
    #
    ######################################################

    scrollTop: (top) ->
      if top?
        @scroller.scrollTop(top)
      else
        @scroller.scrollTop()

    scrollBottom: (bottom) ->
      if bottom?
        @scroller.scrollBottom(bottom)
      else
        @scroller.scrollBottom()

    scrollToEntry: (entry, offset = 0) ->
      displayElement = entry
      top = displayElement.position().top
      bottom = top + displayElement.outerHeight()
      if bottom > @scrollBottom()
        @scrollBottom(bottom + offset)
      if top < @scrollTop()
        @scrollTop(top + offset)

    scrollToBottom: ->
      if lastEntry = @root?.find('.entry:last').view()
        @selectEntry(lastEntry)
        @scrollToEntry(lastEntry)

    scrollToTop: ->
      @selectEntry(@root) if @root?
      @scrollTop(0)