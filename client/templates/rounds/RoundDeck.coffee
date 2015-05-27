Template.RoundDeck.events
  'click': (event) ->
    round = @findRound()

    if round.getCurrentPlayer().userId isnt Meteor.userId()
      alert('You are not the current player')
      return

    player = Players.findOne
      userId: Meteor.userId()

    card = @findCards(
      sort: rank: 1
      limit: 1
    ).fetch()[0]

    hand = Decks.findOne
      name: 'hand'
      playerId: player._id

    hand.appendCard card

    round.nextTurn()
