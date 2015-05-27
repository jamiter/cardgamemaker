Template.GamePage.helpers
  game: ->
    gameId = FlowRouter.getParam 'gameId'

    Games.findOne _id: gameId

  countPlayers: ->
    Players.find(
      gameId: @_id
      userId: $ne: null
    ).count()
