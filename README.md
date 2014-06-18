# Slack Chat - Atom package *Beta*

Slack Chat is an Atom package that integrates the slack messaging client into the editor.
#### With slack chat you can: 
- Send messages
- View message history

# Preview
<img src="http://drive.google.com/uc?export=view&id=0B_FMiWCp_bLQX2xJTkhNdEhpcG8" width=500 />

# Todo
- Fix sluggishness
- Automatically scroll to new messages
- More responsive message input
- Make the commands less buggy
- Enable links
- Display images
- Parse markdown
- Display emoticons
- More customization on placement and theme of Slack Chat

# Usage

![Slack Chat settings](http://drive.google.com/uc?export=view&id=0B_FMiWCp_bLQTTdzZjhQQ2wya0U)
### Icon emoji or image
Select he emoji or image that will be seen by others as your icon.
### Token
This is your token for your team. You can acquire a token under authentication here https://api.slack.com/ 
### Username
The slack api doesn't operate as the user who is sending requests but as a bot that is sending 
requests on behalf of the user. For this reason, you'll need to specify a username to be used.
If you use the same username as you have specified on Slack, you will see your username show up as
"*\#{username} (bot)*". "(bot)" will not appear if your username is not the same as your Slack username.
### Real Time Messaging
Slack Chat can accept and send messages in real time--with a catch. To receive notifications and carry 
on real time conversations you will need to:
- Install the accompanying chrome extension https://chrome.google.com/webstore/detail/slack-chat/lhdjcloiphabhhodmcclbfhcehfddlpc?authuser=1
- Keep a Slack tab open 
- Refresh Slack until you see the `Slack Chat is running` banner.