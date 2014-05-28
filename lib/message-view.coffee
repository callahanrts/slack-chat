{View} = require 'atom'
_ = require 'underscore-plus'

module.exports =
class MessageView extends View
  @content: (message, parent) ->
    team = parent.team
    user = _.findWhere(team, {id: message.user}) if message.user
    @li class: 'message', outlet: 'slackMessage', =>
      # Deleted messages wont have a text object so don't show them.
      if message.text
        lines = message.text.split(/\r\n|\r|\n/g);
        username = if user then user.name else atom.config.get('slack-chat.username')
        @div class: 'user_icon', =>
          if user
            @img src: user.profile.image_24
          else
            @img src: atom.config.get('slack-chat.icon_image'), height: 24, width: 24
        @div "#{username}", class: 'name', outlet: 'memberName'
        @div "#{message.ts}", class: 'time', outlet: 'time'
        @div class: 'text', outlet: 'messageText', =>
          for l in lines
            @div l, class: 'line'

  initialize: (@message, @parent) ->
    @getTime(@message.ts) if @message.text

    
  getTime: (timestamp) ->
    a = new Date(timestamp * 1000)
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    month = months[a.getMonth()]
    date = a.getDate()
    hour = a.getHours()
    min = a.getMinutes()
    if hour > 12
      hour = hour - 12
      t = " pm"
    else
      t = " am"
    @time.text("#{month} #{date} #{hour}:#{min} #{t}")