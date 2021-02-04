
# lib/main

TestCoffeeScript = require './test-coffee-script'
SubAtom = require 'sub-atom'

module.exports =
  activate: ->
    @subs = new SubAtom
    @subs.add atom.commands.add 'atom-workspace', 'test-coffee-script:open': ->
      atom.workspace.getActivePane().activateItem new TestCoffeeScript "I'm Alive!"

  deactivate: ->
    @subs.dispose()
