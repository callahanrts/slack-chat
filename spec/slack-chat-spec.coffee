{WorkspaceView} = require 'atom'
SlackChat = require '../lib/slack-chat'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "SlackChat", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('slack-chat')

  describe "when the slack-chat:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.slack-chat')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'slack-chat:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.slack-chat')).toExist()
        atom.workspaceView.trigger 'slack-chat:toggle'
        expect(atom.workspaceView.find('.slack-chat')).not.toExist()
