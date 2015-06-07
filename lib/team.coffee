
module.exports =
class Team

  constructor: (@client) ->
    @members = {}
    @getTeamMembers()

  getTeamMembers: =>
    @client.get 'users.list', {}, (err, resp) =>
      console.log 'got team'
      @members[member.id] = member for member in resp.body.members

  memberImage: (member=null, message=null) =>
    if member?
      member.profile.image_32
    else if message.icons?
      message.icons.image_64
    else
      "https://slack.global.ssl.fastly.net/5a92/plugins/slackbot/assets/service_128.png"

  memberName: (member, message=null) =>
    if member?
      member.name
    else if message.username?
      message.username
    else
      message.user
