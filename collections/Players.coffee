@Players = new Mongo.Collection 'players',
  transform: (data) ->
    new Player data

class Player extends Model

  @_collection: Players

  init: ->
    handId = Decks.insert
      name: 'hand'
      roundId: @roundId
      playerId: @_id

    cards = Cards.find(
      gameId: @gameId
      roundId: @roundId
      deckId: null
    ,
      limit: 5
      sort: rank: 1
    ).fetch()

    cards.forEach (card) ->
      card.addToDeck handId

  getPlayableCards: ->
    return [] unless @isCurrentPlayer()

    pile = Decks.findOne
      name: 'pile'
      roundId: @roundId

    cards = pile.findCards(
      sort: rank: -1
      limit: 1
    ).fetch()

    target = cards[0]

    playable = []

    hand = Decks.findOne
      name: 'hand'
      playerId: @_id

    for card in hand.findCards().fetch()
      if card.color is target.color or card.type is target.type or card.isBlack()
        playable.push card

    playable.sort (a, b) ->
      a.getPoints() - b.getPoints()

    playable

  isAi: ->
    not @userId

  isHuman: ->
    not @isAi()

  findRound: ->
    Rounds.findOne @roundId

  isCurrentPlayer: ->
    @_id is @findRound()?.getCurrentPlayer()?._id

  _canPlayCard: (card, collection) ->
    playable = collection or @getPlayableCards()

    for possibleCard in playable
      if card._id is possibleCard._id
        return true
    false

  play: (card) ->
    if not @_canPlayCard card
      alert 'You cannot play that card'
    else
      round = @findRound()

      pile = Decks.findOne
        name: 'pile'
        roundId: @roundId

      pile.appendCard card

      card.run round
      round.nextTurn()

  aiPlay: ->
    Meteor.setTimeout =>
      if @isCurrentPlayer()
        playable = @getPlayableCards()
        if playable.length is 0
          hand = Decks.findOne
            name: 'hand'
            roundId: @roundId
            playerId: @_id

          deck = Decks.findOne
            name: 'deck'
            roundId: @roundId

          card = Cards.findOne
            deckId: deck._id
          ,
            sort: rank: 1

          card.addToDeck hand._id

          setTimeout =>
            @findRound().nextTurn()
          , 400
        else
          @play playable[0]
    , 1000

  calculateScore: ->
    hand = Decks.findOne
      name: 'hand'
      roundId: @roundId
      playerId: @_id

    hand.findCards().fetch().reduce (points, card) ->
      points + card.getPoints()
    , 0
