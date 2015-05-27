Template.PlayerHand.helpers
  cards: ->
    deck = Decks.findOne
      name: 'hand'
      playerId: @_id

    deck?.findCards() or []
