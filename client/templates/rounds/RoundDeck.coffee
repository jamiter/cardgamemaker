Template.RoundDeck.events
  'click': (event) ->
    round = @findRound()

    if round.getCurrentPlayer().userId isnt Meteor.userId()
      alert('You are not the current player')
      return

    player = Players.findOne
      roundId: @roundId
      userId: Meteor.userId()

    card = @findFirstCard()

    hand = Decks.findOne
      name: 'hand'
      playerId: player._id

    hand.appendCard card

    round.nextTurn()
