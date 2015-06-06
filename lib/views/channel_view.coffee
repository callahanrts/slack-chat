
module.exports =
class ChannelView
  constructor: (@parent, @client) ->

    @channelView = document.createElement('ul')
    @channelView.classList.add('channels')

    console.log @parent

    @client.get 'channels.list', {}, (err, resp) =>
      @channels = resp.body.channels
      for channel in @channels
        ch = document.createElement('li')
        ch.classList.add('channel')
        ch.textContent = channel.name
        @channelView.appendChild(ch)

    @client.get 'im.list', {}, (err, resp) =>
      @ims = resp.body.ims

    ## Create root element
    #@slackView = document.createElement('div')
    #@slackView.classList.add('slack-chat')

    ## Create message element
    #message = document.createElement('div')
    #message.textContent = "The SlackChat package is Alive! It's ALIVE!"
    #message.classList.add('message')
    #@slackView.appendChild(message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @channelView.remove()

  getElement: ->
    @channelView

