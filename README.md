
# Slack Chat - Atom package *Beta*

Slack Chat is an Atom package that integrates the slack messaging client into the editor.
#### With slack chat you can:
- Send and receive messages in real time
- View message history

# Installation
- Install slack-chat from the atom package manager
- Log in to slack with the window that was opened in your browser

  <img src="http://drive.google.com/uc?export=view&id=0B_FMiWCp_bLQems3NTlIUjlzWWM" width="400px" />

- Authorize the sc-client application

  <img src="http://drive.google.com/uc?export=view&id=0B_FMiWCp_bLQYm9HSi0xY2RMQVU" width="400px" />

- Restart atom

# Usage

### Toggle Slack Chat Panel
`cmd+m` toggles the panel by default.

### Overridable commands
```cson
# keymap.cson
'atom-text-editor, atom-workspace':
  'ctrl-m': 'slack-chat:toggle'
```


# Settings

### Token
This is your token for your team. Slack Chat should manage this for you. If you need to sign in with a different account/team, remove this token and reload Atom.

# Preview
<img src="http://drive.google.com/uc?export=view&id=0B_FMiWCp_bLQNlluR2MwRkNWVG8" width="400px" />
<img src="http://drive.google.com/uc?export=view&id=0B_FMiWCp_bLQOEM1ZjZvUDRhVEk" width="400px" />

# Todo
- User Status (online/offline)
- Enable links
- Create Keybindings for selection
- Display images
- Parse markdown
- Display emoticons


