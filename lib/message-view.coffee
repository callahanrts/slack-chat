{View} = require 'atom'

module.exports =
class MessageView extends View
  @content: (message) ->
    # console.log message
    @div class: 'message', =>
      @div class: 'icon glyphicon glyphicon-envelope'
      @div "#{message.user}", class: 'name', outlet: 'memberName'
      @div "#{message.text}", class: 'name', outlet: 'memberName'
      @div "#{message.ts}", class: 'time', outlet: 'time'

  initialize: (message) ->
    @getTime(message.ts)
    # @fileName.text(@file.name)
    # @fileName.attr('data-name', @file.name)
    # @fileName.attr('data-path', relativeFilePath)
    
  getTime: (timestamp) ->
    a = new Date(timestamp * 1000)
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    month = months[a.getMonth()]
    date = a.getDate()
    hour = a.getHours()
    min = a.getMinutes()
    @time.text("#{month} #{date} #{hour}:#{min}")