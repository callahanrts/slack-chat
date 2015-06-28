
_ = require 'underscore-plus'

module.exports =
class Team

  constructor: (@client) ->
    @members = []
    @channels = []

    @getChannels()
    @getTeamMembers()
    @getEmoji()

  # Creates an array that stores the channels a user has access to. It adds
  # the `channel` object so it can be used in the same way as members.
  getChannels: =>
    for channel in @client.channels.concat(@client.groups)
      channel.channel = { id: channel.id }
      @channels.push channel unless channel.is_archived or (not channel.is_member and not channel.is_group)

  # Retrieves any custom emoji from slack the user has access to
  getEmoji: =>
    @client.get 'emoji.list', {}, (err, resp) =>
      @emoji = resp.body.emoji

  # Parse team members with channel ids (for ims) from rtm.start of sc-client
  getTeamMembers: =>
    for user in @client.users
      unless user.deleted
        user.channel = _.findWhere(@client.ims, { user: user.id })
        user.image = @memberImage(user)
        @members.push user

  # Images are inconsistent. They come from bots or people or channels or whatever else
  # slack decides to slap an image on. There isn't much of consistency with their location
  # in objects so we parse them here.
  memberImage: (member=null, message=null) =>
    if member?
      member.profile.image_32
    else if message.icons?
      message.icons.image_64
    else
      "https://slack.global.ssl.fastly.net/5a92/plugins/slackbot/assets/service_128.png"

  # Same story as images (above) but with the name of the person/channel/bot/etc.
  memberName: (member, message=null) =>
    if member?
      member.name
    else if message.username?
      message.username
    else
      message.user

  # Find a slack user object given only their user id
  memberWithId: (id) =>
    _.findWhere(@members, { id: id })

  # Since members stores all members including self, we filter out self with this method
  membersNotMe: =>
    _.reject(@members, (member) => member.id is @client.me.id)

  # Chat's are the combination of members and channels. We combine them here and return
  # the object we're looking for that contains the given channel id
  chatWithChannel: (channel) =>
    chats = @members.concat(@channels)
    _.find chats, (chat) =>
      chat.channel? and chat.channel.id is channel

  # Try to turn custom emoji into an image tag and return it. Otherwise just return
  # the param
  customEmoji: (match) =>
    return match unless @emoji
    emoji = match.replace(/:/g, '')
    if @emoji[emoji]?
      @customEmojiImage(@emoji[emoji], match)
    else
      match

  # Get create an image from a custom emoji
  customEmojiImage: (emoji, match) =>
    if emoji.match(/http/)?
      "<img src='#{emoji}' class='emoji' title='#{match.replace(/:/g, '')}' alt='#{match.replace(/:/g, '')}' />"
    else
      @customEmoji(":#{emoji.split(':')[1]}:")


  # Replace emoji short hand with an image tag for the emoji
  parseCustomEmoji: (text) =>
    # Find and replace custom emoji with images
    emoji = text.match(/:\S+:/g)
    if emoji
      text = text.replace(match, @customEmoji(match)) for match in emoji
    text

  # Update user presence variables. This will later be used to show the green or gray
  # dots indicating whether or not a user is online.
  setPresence: (user, presence) =>
    for member in @members
      member.presence = presence if member.id is user

  # If a user is unknown (bot) create a pseudo user object for the unknown user
  unknownUser: (message) =>
    image: @memberImage(null, message)
    name: @memberName(null, message)


