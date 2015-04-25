HtmlEntities = require('html-entities').AllHtmlEntities
htmlEntities = new HtmlEntities()
XmlEntities = require('html-entities').XmlEntities
xmlEntities = new XmlEntities()
crypto = require('crypto')
string = require('string')

module.exports =
  activate: ->
    atom.commands.add 'atom-workspace', 'text-manipulation:base64-encode', => @convert @encodeBase64
    atom.commands.add 'atom-workspace', 'text-manipulation:base64-decode', => @convert @decodeBase64
    atom.commands.add 'atom-workspace', 'text-manipulation:html-encode', => @convert @encodeHtml
    atom.commands.add 'atom-workspace', 'text-manipulation:html-decode', => @convert @decodeHtml
    atom.commands.add 'atom-workspace', 'text-manipulation:xml-encode', => @convert @encodeXml
    atom.commands.add 'atom-workspace', 'text-manipulation:xml-decode', => @convert @decodeXml
    atom.commands.add 'atom-workspace', 'text-manipulation:sql-encode', => @convert @encodeSql
    atom.commands.add 'atom-workspace', 'text-manipulation:sql-decode', => @convert @decodeSql
    atom.commands.add 'atom-workspace', 'text-manipulation:url-encode', => @convert @encodeUrl
    atom.commands.add 'atom-workspace', 'text-manipulation:url-decode', => @convert @decodeUrl
    atom.commands.add 'atom-workspace', 'text-manipulation:hash-md5', => @convert @hashMD5
    atom.commands.add 'atom-workspace', 'text-manipulation:hash-sha1', => @convert @hashSHA1
    atom.commands.add 'atom-workspace', 'text-manipulation:hash-sha256', => @convert @hashSHA256
    atom.commands.add 'atom-workspace', 'text-manipulation:hash-sha512', => @convert @hashSHA512
    atom.commands.add 'atom-workspace', 'text-manipulation:format-camelize', => @convert @formatCamelize
    atom.commands.add 'atom-workspace', 'text-manipulation:format-dasherize', => @convert @formatDasherize
    atom.commands.add 'atom-workspace', 'text-manipulation:format-underscore', => @convert @formatUnderscore
    atom.commands.add 'atom-workspace', 'text-manipulation:format-slugify', => @convert @formatSlugify
    atom.commands.add 'atom-workspace', 'text-manipulation:format-humanize', => @convert @formatHumanize
    atom.commands.add 'atom-workspace', 'text-manipulation:whitespace-trim', => @convert @whitespaceTrim
    atom.commands.add 'atom-workspace', 'text-manipulation:whitespace-collapse', => @convert @whitespaceCollapse
    atom.commands.add 'atom-workspace', 'text-manipulation:whitespace-remove', => @convert @whitespaceRemove
    atom.commands.add 'atom-workspace', 'text-manipulation:whitespace-emptylines', => @convert @whitespaceEmptyLines
    atom.commands.add 'atom-workspace', 'text-manipulation:whitespace-tabify', => @convert @whitespaceTabify
    atom.commands.add 'atom-workspace', 'text-manipulation:whitespace-untabify', => @convert @whitespaceUntabify
    atom.commands.add 'atom-workspace', 'text-manipulation:strip-punctuation', => @convert @stripPunctuation

  convert: (converter) ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()
    #if selections.length == 1 and selections[0].isEmpty
    #  editor.moveToFirstCharacterOfLine()
    #  editor.selectToEndOfLine()
    #  selections = editor.getSelections()
    selection.insertText(converter(selection.getText()), {'select': true}) for selection in selections

  encodeBase64: (text) ->
    new Buffer(text).toString('base64')

  decodeBase64: (text) ->
    if /^[A-Za-z0-9+/=]+$/.test(text)
      new Buffer(text, 'base64').toString('utf8')
    else
      text

  encodeHtml: (text) ->
    htmlEntities.encodeNonUTF(text)

  decodeHtml: (text) ->
    htmlEntities.decode(text)

  encodeXml: (text) ->
    xmlEntities.encodeNonUTF(text)

  decodeXml: (text) ->
    xmlEntities.decode(text)

  encodeSql: (text) ->
    escape_sql(text)

  decodeSql: (text) ->
    unescape_sql(text)

  encodeUrl: (text) ->
    encodeURIComponent(text)

  decodeUrl: (text) ->
    decodeURIComponent(text)

  hashMD5: (text) ->
    hash = crypto.createHash('md5')
    hash.update(new Buffer(text))
    hash.digest('hex')

  hashSHA1: (text) ->
    hash = crypto.createHash('sha1')
    hash.update(new Buffer(text))
    hash.digest('hex')

  hashSHA256: (text) ->
    hash = crypto.createHash('sha256')
    hash.update(new Buffer(text))
    hash.digest('hex')

  hashSHA512: (text) ->
    hash = crypto.createHash('sha512')
    hash.update(new Buffer(text))
    hash.digest('hex')

  formatCamelize: (text) ->
    string(text).camelize().s

  formatDasherize: (text) ->
    string(text).dasherize().s

  formatUnderscore: (text) ->
    string(text).underscore().s

  formatSlugify: (text) ->
    string(text).slugify().s

  formatHumanize: (text) ->
    string(text).humanize().s

  whitespaceTrim: (text) ->
    lines = (string(line).replace(/\s+$/, "").s for line in text.split('\n'))
    lines.join('\n')

  whitespaceCollapse: (text) ->
    string(text).collapseWhitespace().s

  whitespaceRemove: (text) ->
    string(text).collapseWhitespace().s.replace(/\s+/g, '')

  whitespaceEmptyLines: (text) ->
    lines = (line for line in text.split('\n') when line.length > 0)
    lines.join('\n')

  whitespaceTabify: (text) ->
    editor = atom.workspace.getActiveTextEditor()
    tabLength = editor.getTabLength()
    lines = (tabify(line, tabLength) for line in text.split('\n'))
    lines.join('\n')

  whitespaceUntabify: (text) ->
    editor = atom.workspace.getActiveTextEditor()
    tabLength = editor.getTabLength()
    lines = (untabify(line, tabLength) for line in text.split('\n'))
    lines.join('\n')

  stripPunctuation: (text) ->
    string(text).stripPunctuation().s

# Helper functions

tabify = (str, tabLength) ->
  [start, count] = countTabs(str, tabLength)
  tabs = string('\t').repeat(count // tabLength).s
  spaces = string(' ').repeat(count %% tabLength).s
  tabs + spaces + str.substr(start)

untabify = (str, tabLength) ->
  [start, count] = countTabs(str, tabLength)
  spaces = string(' ').repeat(count).s
  spaces + str.substr(start)

countTabs = (str, tabLength) ->
  start = str.search(/[^\s]/)
  if start < 0
    start = str.length
  count = 0
  for ch in str.substr(0, start)
    switch ch
      when ' ' then count += 1
      when '\t' then count = (count // tabLength + 1) * tabLength
  [start, count]

escape_sql = (str) ->
  str.replace(/[\0\b\t\n\r\\"'%\x1a]/g, (char) ->
    switch char
      when "\0" then "\\0"
      when "\b" then "\\b"
      when "\t" then "\\t"
      when "\n" then "\\n"
      when "\r" then "\\r"
      when "\"" then "\\\""
      when "'" then "\\'"
      when "\\" then "\\\\"
      when "%" then "\\%"
      when "\x1a" then "\\z"
  )

unescape_sql = (str) ->
  str.replace(/\\[0btnr"'\\%z]/g, (char) ->
    switch char
      when "\\0" then "\0"
      when "\\b" then "\b"
      when "\\t" then "\t"
      when "\\n" then "\n"
      when "\\r" then "\r"
      when "\\\"" then "\""
      when "\\'" then "'"
      when "\\\\" then "\\"
      when "\\%" then "%"
      when "\\z" then "\x1a"
  )
