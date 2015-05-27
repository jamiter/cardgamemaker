Template.RoundScoreboard.helpers
  players: ->
    Players.find(roundId: @_id).fetch().sort (a, b) ->
      a.calculateScore() - b.calculateScore()

  winnerName: ->
    if @winnerId
      Players.findOne(@winnerId)?.name
