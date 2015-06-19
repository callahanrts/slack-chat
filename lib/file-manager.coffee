
_ = require 'underscore-plus'

module.exports =
class FileManager
  VALID_FILE_TYPES = ["auto", "text", "applescript", "boxnote", "c", "csharp", "cpp",
    "css", "csv", "clojure", "coffeescript", "cfm", "diff", "erlang", "go", "groovy",
    "html", "haskell", "java", "javascript", "latex", "lisp", "lua", "matlab",
    "markdown", "objc", "php", "perl", "post", "puppet", "python", "r", "ruby", "sql",
    "scala", "scheme", "shell", "smalltalk", "tsv", "vb", "vbscript", "xml", "yaml"]

  instance = null

  constructor: (@stateController) ->
    if instance
      return instance
    else
      instance = this

    @client = @stateController.client

  uploadSelection: (channels, comment) =>
    atom.workspace.observeTextEditors (editor) =>
      @uploadFile(editor, channels, comment)

  uploadFile: (editor, channels, comment) =>
    @client.post "files.upload",
      content: editor.getSelectedText()
      filetype: @getFileTypeFromGrammar(editor)
      initial_comment: comment
      channels: channels.join(',')
    , (err, resp) =>
      if resp.body.ok
        chat = @stateController.team.chatWithChannel(channels[0])
        console.log chat
        @stateController.setState('chat', chat)

  getFileTypeFromGrammar: (editor) =>
    grammar = editor.getGrammar().name
    filetype = _.find VALID_FILE_TYPES, (type) =>
      grammar.toLowerCase() is type
    filetype or 'auto'

