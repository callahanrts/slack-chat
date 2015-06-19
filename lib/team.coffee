
_ = require 'underscore-plus'

module.exports =
class Team

  constructor: (@client) ->
    @members = []
    @channels = []

    @getChannels()
    @getTeamMembers()
    @getEmoji()

  getChannels: =>
    for channel in @client.channels
      channel.channel = { id: channel.id }
      @channels.push channel

  getEmoji: =>
    @client.get 'emoji.list', {}, (err, resp) =>
      @emoji = resp.body.emoji

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

  chatWithChannel: (channel) =>
    chats = @members.concat(@channels)
    _.find chats, (chat) =>
      chat.channel? and chat.channel.id is channel

  customEmoji: (match) =>
    return match unless @emoji
    emoji = match.replace(/:/g, '')
    if @emoji[emoji]?
      @customEmojiImage(@emoji[emoji], match)
    else
      match

  customEmojiImage: (emoji, match) =>
    if emoji.match(/http/)?
      "<img src='#{emoji}' class='emoji' title='#{match.replace(/:/g, '')}' alt='#{match.replace(/:/g, '')}' />"
    else
      @customEmoji(":#{emoji.split(':')[1]}:")


  parseCustomEmoji: (text) =>
    # Find and replace custom emoji with images
    emoji = text.match(/:\S+:/g)
    if emoji
      text = text.replace(match, @customEmoji(match)) for match in emoji
    text

  setPresence: (user, presence) =>
    for member in @members
      member.presence = presence if member.id is user

  unknownUser: (message) =>
    image: @memberImage(null, message)
    name: @memberName(null, message)


