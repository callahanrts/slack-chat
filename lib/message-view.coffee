{View} = require 'atom'
_ = require 'underscore-plus'

module.exports =
class MessageView extends View
  @content: (message, team) ->
    user = _.findWhere(team, {id: message.user}) if message.user
    lines = message.text.split(/\r\n|\r|\n/g);
    username = if user then user.name else atom.config.get('slack-chat.username')
    @div class: 'message', =>
      @div class: 'user_icon', =>
        if user
          @img src: user.profile.image_24
        else
          @div class: 'icon glyphicon glyphicon-user'
      @div "#{username}", class: 'name', outlet: 'memberName'
      @div "#{message.ts}", class: 'time', outlet: 'time'
      @div class: 'text', outlet: 'memberName', =>
        for l in lines
          @div l, class: 'line'

  initialize: (message, team) ->
    user = _.findWhere(team, {id: message.user}) if message.user
    @getTime(message.ts)
    
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