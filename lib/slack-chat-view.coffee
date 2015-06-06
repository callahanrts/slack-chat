
module.exports =
class SlackChatView
  constructor: (serializedState) ->

    # Create root element
    @slackView = document.createElement('div')
    @slackView.classList.add('slack-chat')

    # Create message element
    message = document.createElement('div')
    message.textContent = "The SlackChat package is Alive! It's ALIVE!"
    message.classList.add('message')
    @slackView.appendChild(message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @slackView.remove()

  getElement: ->
    @slackView
