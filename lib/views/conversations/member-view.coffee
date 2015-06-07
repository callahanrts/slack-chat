
ChatView = require "../chat/chat-view"
{$, View} = require 'atom-space-pen-views'

module.exports =
class MemberView extends View
  @content: (@parent, @member) ->
    @li id: @member.id, class: 'member', click: 'showConversation', =>
      @span class: 'dot'
      @span @member.name

  initialize: (@parent, @member) ->

  showConversation: () ->
    console.log arguments

