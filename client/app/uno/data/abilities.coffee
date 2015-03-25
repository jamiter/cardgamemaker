abilities =
  turn: (round, cb) ->
    round.swapDir()
    cb() if cb
  skip: (round, cb) ->
    round.nextTurn()
    cb() if cb
