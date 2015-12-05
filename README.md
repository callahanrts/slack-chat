
# Slack Chat

Slack Chat is an Atom package that integrates the slack messaging client into the atom text editor.

# Preview
<img src="http://drive.google.com/uc?export=view&id=0B_FMiWCp_bLQNlluR2MwRkNWVG8" width="47%" />
<img src="http://drive.google.com/uc?export=view&id=0B_FMiWCp_bLQOEM1ZjZvUDRhVEk" width="47%" />


# Installation
- Get client id and secret keys by [creating a slack app](https://api.slack.com/applications/new)
  - Name: pick an arbitrary name
  - URL: http://slack-chat.herokuapp.com/slack
  - Redirect URI(s): http://slack-chat.herokuapp.com/slack
  - Description: not necessary
  - Team: Your team, but the app seems to work with other teams as well.
- Go to the slack-chat package settings in atom
  - Paste in your client id and secret
- When the browser opens, select the team you'd like to use with atom<br>
  <img src="http://i.imgur.com/J5n1H8y.png" width="47%" />
- Authorize the app<br>
  <img src="http://i.imgur.com/v52GY9b.png" width="47%" />
- Copy the received token into the slack-chat package settings.
- Restart atom

# Usage

1. [Keybindings](https://github.com/callahanrts/slack-chat/wiki/Slack-Chat-Keybindings)
1. [Settings]()


# Todo
- [x] Send/receive messages in real time
- [x] Real time message notification system
- [x] User Status (online/offline)
- [x] Create Keybindings for selection
- [x] Parse markdown
- [x] Display emoji (regular and custom)
- [x] Display/download images/files
- [x] Display images/gifs/open graph data when a url is posted
- [x] Send a selection of text as a message/file
- [ ] Discover channels the user is not currently a part of
- [ ] Refresh when a user is invited to a channel
- [ ] Manually resize panel in chat views
- [ ] Upload files
- [ ] Code highlight for markdown
- [ ] Fix markdown differences between github flavored and Slack
- [ ] Load previous when at top of scroll
- [ ] Search for messages
- [ ] [User requests](https://github.com/callahanrts/slack-chat/issues)
