@CardAbilities =
  next: (round) ->
    round.nextTurn()
  turn: (round) ->
    round.swapDir()
  skip: (round) ->
    round.nextTurn()
  draw2: (round) ->
