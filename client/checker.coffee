# Nikolai Warner - initially dreamed and created in four hours on April 28, 2013

class @ChecoreGame
  constructor: (options={}) ->
    @width = options.width || 8
    @squares = []

    @turn = 1
    @player1 = {}
    @player2 = {}

    @draw_board()

    if options.game
      Session.set('current_game', options.game)
      @redraw_board()
    else
      @load_checores()
      @new_game()

    if @game_still_active()
      $('.end_game').show()
      @setup_checore_events()
    else
      $('.end_game').hide()
    @update_score()
    @show_turn_info()
    setTimeout (-> $('.checore').removeClass('flip')), 5000


  draw_board: =>
    $('.square').remove()
    $board = $('.board')
    for y in [1..@width]
      for x in [1..@width]
        $square = $('<div>')
        $square.addClass 'square'
        $square.addClass "#{x}x#{y}"
        $square.data 'x', x
        $square.data 'y', y
        $board.append $square


  load_checores: =>
    $('.checore').remove()
    every_other = true
    for y in [1..@width]
      every_other = !every_other
      for x in [1..@width]
        player = undefined
        if every_other
          every_other = false
          if y == 1 || y == 2 || y == 3
            player = 1
          if y == @width - 2 || y == @width - 1 || y == @width
            player = 2

          if player
            @create_checore(player, x, y, true)
        else
          every_other = true


  create_checore: (player, x, y, visible=false) =>
    $checore = $('<div>')
    $checore.addClass 'checore'
    if visible
      $checore.addClass 'flip'
    $checore.data 'player', player

    $front = $("<div class='front'></div><div class='back'><div class='number'>#{player}</div></div>")
    $checore.append $front

    $('.board').append $checore
    @place_checore $checore, x, y


  setup_checore_events: =>
    $('.checore').draggable
      containment: '.board'
      cursor: 'pointer'
    $('.square').droppable
      drop: @make_a_move


  make_a_move: (event, ui) =>
    $checore = ui.draggable
    $new_square = $(event.target)

    if @can_move $checore, $new_square
      @place_checore($checore, $new_square.data('x'), $new_square.data('y'))
      @save_game()
      @next_turn()
    else
      @place_checore($checore, $checore.data('x'), $checore.data('y'))


  can_move: ($checore, $new_square) =>
    x = $checore.data('x')
    y = $checore.data('y')
    new_x = $new_square.data('x')
    new_y = $new_square.data('y')
    @is_square_free(new_x, new_y) &&
    (@is_diagonal_move(x, y, new_x, new_y) || @is_diagonal_jump(x, y, new_x, new_y))


  is_square_free: (x, y) =>
    !(@find_checore_at(x, y))


  is_diagonal_move: (x, y, new_x, new_y) =>
    if (y == new_y + 1 && x == new_x + 1) || (y == new_y + 1 && x == new_x - 1) || (y == new_y - 1 && x == new_x + 1) || (y == new_y - 1 && x == new_x - 1)
      return true


  is_diagonal_jump: (x, y, new_x, new_y) =>
    if (y == new_y + 2 && x == new_x + 2)
      jump_x = x - 1
      jump_y = y - 1
    else if (y == new_y + 2 && x == new_x - 2)
      jump_x = x + 1
      jump_y = y - 1
    else if (y == new_y - 2 && x == new_x + 2)
      jump_x = x - 1
      jump_y = y + 1
    else if (y == new_y - 2 && x == new_x - 2)
      jump_x = x + 1
      jump_y = y + 1

    if !@is_square_free(jump_x, jump_y)
      @kill_checore(jump_x, jump_y)
      return true


  kill_checore: (x, y) =>
    @find_checore_at(x, y).remove()
    @update_score()


  find_checore_at: (x, y) =>
    $checore = false
    $('.checore').each (index, checore) =>
      if $(checore).data('y') == y && $(checore).data('x') == x
        $checore = $(checore)
    $checore


  update_score: =>
    @player1.score = 0
    @player2.score = 0
    $('.checore').each (index, checore) =>
      if $(checore).data('player') == 1
        @player1.score = @player1.score + 1
      if $(checore).data('player') == 2
        @player2.score = @player2.score + 1


  place_checore: ($checore, x, y) =>
    $checore.css
      top: (y - 1) * 50 + 10
      left: (x - 1) * 50 + 10
    $checore.data('x', x)
    $checore.data('y', y)


  redraw_board: =>
    $('.checore').remove()
    game = Session.get('current_game')
    for peice in game.peices
      @create_checore(peice.player, peice.x, peice.y)


  next_turn: =>
    if @turn == 1
      @turn = 2
    else @turn = 1
    @rotate_board()
    @show_turn_info()


  rotate_board: =>
    #$('.board').toggleClass 'player2'


  show_turn_info: =>
    $scoreboard = $('.scoreboard')
    $scoreboard.hide()
    $scoreboard.html "Player #{@turn}. <div class='pull-right'>#{@player1.score} / #{@player2.score}</div>"
    $scoreboard.fadeIn(3000)


  count_peices: =>
    peices = []
    $('.checore').each (index, checore) ->
      data = $(checore).data()
      peices.push
        player: data.player
        x: data.x
        y: data.y
    return peices


  new_game: =>
    game =
      created_at: Date.now()
      ended_at: undefined
      id: Math.random().toString(36).substring(7)
      peices: @count_peices()

    Session.set('current_game', game)

    @save_game()
    Meteor.Router.to("/games/#{Session.get('current_game').id}")

    return game


  save_game: =>
    game = Session.get('current_game')
    game.peices = @count_peices()
    if window.Games.findOne {id: game.id}
      window.Games.update {_id: game._id}, game
    else
      window.Games.insert game


  end_game: =>
    game = Session.get('current_game')
    game.ended_at = Date.now()
    Session.set('current_game', game)
    @save_game()

  game_still_active: =>
    !Session.get('current_game').ended_at?

