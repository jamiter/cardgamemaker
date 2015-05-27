Template.GameTable.helpers
  round: ->
    roundId = FlowRouter.getParam 'roundId'

    Rounds.findOne roundId

  players: ->
    roundId = FlowRouter.getParam 'roundId'

    Players.find roundId: roundId

  deck: ->
    roundId = FlowRouter.getParam 'roundId'

    Decks.findOne
      name: 'deck'
      roundId: roundId

  pile: ->
    roundId = FlowRouter.getParam 'roundId'

    Decks.findOne
      name: 'pile'
      roundId: roundId

  hasFinished: ->
    roundId = FlowRouter.getParam 'roundId'

    round = Rounds.findOne roundId

    round?.hasFinished()

  winnerName: ->
    roundId = FlowRouter.getParam 'roundId'

    round = Rounds.findOne roundId

    if round?.winnerId
      Players.findOne(round.winnerId)?.name
