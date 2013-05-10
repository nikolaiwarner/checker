# Nikolai Warner - initially dreamed and created in four hours on April 28, 2013


class CheckerGame
  constructor: (options={}) ->
    @width = options.width || 8
    @squares = []

    @turn = 1
    @player1 = {}
    @player2 = {}

    @draw_board()
    @load_checkers()
    @setup_checker_events()
    @update_score()
    @show_turn_info()

    setTimeout (-> $('.checker').removeClass('flip')), 5000


  draw_board: =>
    $board = $('.board')
    for y in [1..@width]
      for x in [1..@width]
        $square = $('<div>')
        $square.addClass 'square'
        $square.addClass "#{x}x#{y}"
        $square.data 'x', x
        $square.data 'y', y
        $board.append $square


  load_checkers: =>
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
            $checker = $('<div>')
            $checker.addClass 'checker flip'
            $checker.data 'player', player

            $front = $("<div class='front'></div><div class='back'><div class='number'>#{player}</div></div>")
            $checker.append $front

            $('.board').append $checker
            @place_checker $checker, x, y
        else
          every_other = true


  setup_checker_events: =>
    $('.checker').draggable
      containment: '.board'
      cursor: 'pointer'
    $('.square').droppable
      drop: @make_a_move


  make_a_move: (event, ui) =>
    $checker = ui.draggable
    $new_square = $(event.target)

    if @can_move $checker, $new_square
      @place_checker($checker, $new_square.data('x'), $new_square.data('y'))
      @next_turn()
    else
      @place_checker($checker, $checker.data('x'), $checker.data('y'))


  can_move: ($checker, $new_square) =>
    x = $checker.data('x')
    y = $checker.data('y')
    new_x = $new_square.data('x')
    new_y = $new_square.data('y')
    @is_square_free(new_x, new_y) &&
    (@is_diagonal_move(x, y, new_x, new_y) || @is_diagonal_jump(x, y, new_x, new_y))


  is_square_free: (x, y) =>
    !(@find_checker_at(x, y))


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
      @kill_checker(jump_x, jump_y)
      return true


  kill_checker: (x, y) =>
    @find_checker_at(x, y).remove()
    @update_score()


  find_checker_at: (x, y) =>
    $checker = false
    $('.checker').each (index, checker) =>
      if $(checker).data('y') == y && $(checker).data('x') == x
        $checker = $(checker)
    $checker


  update_score: =>
    @player1.score = 0
    @player2.score = 0
    $('.checker').each (index, checker) =>
      if $(checker).data('player') == 1
        @player1.score = @player1.score + 1
      if $(checker).data('player') == 2
        @player2.score = @player2.score + 1


  place_checker: ($checker, x, y) =>
    $checker.css
      top: (y - 1) * 50 + 10
      left: (x - 1) * 50 + 10
    $checker.data('x', x)
    $checker.data('y', y)


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


Meteor.startup ->
  $ ->
    window.checkerGame = new CheckerGame()
