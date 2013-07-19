window.Games = new Meteor.Collection("games")

Meteor.autosubscribe ->
  Meteor.subscribe("games")


Template.new_game.events
  "click .new_game": ->
    window.checoreGame = new ChecoreGame()

Template.all_games.helpers
  games: ->
    Games.find {}
  created_time: ->
    moment(@created_at).calendar()
  ended_time: ->
    moment(@ended_at).calendar()
  game_length_in_time: ->
    if @ended_at
      moment.duration(@created_at - @ended_at, 'ms').humanize()
    else
      ''
  score: ->
    player1 = 0
    player2 = 0
    for peice in @peices
      if peice.player == 1
        player1 = player1 + 1
      else
        player2 = player2 + 1
    "#{player1}/#{player2}"


Template.board.events
  "click .end_game": ->
    window.checoreGame.end_game()


Meteor.Router.add
  '/games/:id': (id) ->
    $('.all_games').hide()
    game = Games.findOne { id: id }
    console.log game
    if game
      window.checoreGame = new ChecoreGame({game: game})
    else
      console.log 'game not found'
  '/games': ->
    $('.all_games').show()
  '*': 'not_found'
