
# lib/html-tab

TestCoffeeScriptView = require './test-coffee-script-view'

module.exports =
class TestCoffeeScript
  constructor: (@tabTitle) ->

  getTitle:     -> @tabTitle
  getViewClass: -> TestCoffeeScriptView
