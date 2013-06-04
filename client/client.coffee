window.Games = new Meteor.Collection("games")

Meteor.autosubscribe ->
  Meteor.subscribe("games")


Template.new_game.events
  "click .new_game": ->
    window.checoreGame = new @ChecoreGame()


Meteor.startup ->
  $ ->

