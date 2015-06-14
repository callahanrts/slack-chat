
_ = require 'underscore-plus'

module.exports =
class Team

  constructor: (@client) ->
    @members = []
    @channels = []

    @getChannels()
    @getTeamMembers()

  getChannels: =>
    for channel in @client.channels
      channel.channel = { id: channel.id }
      @channels.push channel

  # Parse team members with channel ids (for ims) from rtm.start of sc-client
  getTeamMembers: =>
    for user in @client.users
      user.channel = _.findWhere(@client.ims, { user: user.id })
      user.image = @memberImage(user)
      @members.push user

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

  memberWithId: (id) =>
    _.findWhere(@members, { id: id })

  membersNotMe: =>
    _.reject(@members, (member) => member.id is @client.me.id)

  unknownUser: (message) =>
    image: @memberImage(null, message)
    name: @memberName(null, message)


