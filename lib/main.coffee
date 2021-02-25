
# lib/main

TestCoffeeScript = require './test-coffee-script'
SubAtom = require 'sub-atom'

module.exports =
  activate: ->
    @subs = new SubAtom
    @subs.add atom.commands.add 'atom-workspace', 'test-coffee-script:open': ->
      atom.workspace.getActivePane().activateItem new TestCoffeeScript "Bezier Editor"

  deactivate: ->
    @subs.dispose()
    if (@toolBar)
      @toolBar.removeItems()
      @toolBar = null

  consumeToolBar: (getToolBar) ->
    @toolBar = getToolBar('test-coffee-script')

    @toolBar.addButton
      icon: 'tools',
      callback: 'test-coffee-script:open',
      tooltip: 'Edit Bezier'
