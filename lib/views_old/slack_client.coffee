
{$} = require 'atom-space-pen-views'

module.exports =
class SlackClient
  SLACK_API = "https://slack.com/api"
  instance = null

  constructor: (token) ->
    @token = token
    # Ensure this class is a singleton
    return instance if instance
    instance = this

  get: (path, options={}) =>
    options['token'] = @token
    $.get "#{SLACK_API}/#{path}", options

  post: (path, options) =>
    $.post "#{SLACK_API}/#{path}", options

  @getInstance: ->
    return new @

# U02A3NX34