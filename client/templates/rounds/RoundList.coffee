Template.RoundList.helpers
  rounds: ->
    options =
      sort:
        finishedAt: 1
        startedAt: 1

    if @_id
      Rounds.find gameId: @_id, options
    else
      Rounds.find {}, options
