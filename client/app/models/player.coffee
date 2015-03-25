class Player

  # @configure 'Player', 'status', '_ai', 'name', 'points', 'hand'

  # @extend Spine.Model.Local

  #@hasOne 'hand', 'models/deck'

  # @belongsTo 'round', 'models/round'
  # @belongsTo 'user', 'models/user'

  @defaults:
    _ai: false
    points: 0

  constructor: ->
    super

    @hand = Deck.create()

  getPlayableCards: ->
    return [] unless @isCurrentPlayer()

    round = @round()
    target = round.pile.last()

    playable = []

    for card in @hand.all()
      if card.color is target.color or card.type is target.type or card.isBlack()
        playable.push card

    playable

  isAi: ->
    @_ai

  isHuman: ->
    not @isAi()

  isCurrentPlayer: ->
    @round().getCurrentPlayer().eql(this)

  _canPlayCard: (card, collection) ->
    playable = collection or @getPlayableCards()

    for possibleCard in playable
      if card.eql possibleCard
        return true
    false

  play: (card) ->
    if not @_canPlayCard card
      alert 'You cannot play that card'
    else
      round = @round()
      round.pile.drawFrom @hand, card
      card.run round, =>
        round.nextTurn()

  aiPlay: () ->
    setTimeout =>
      if @isCurrentPlayer()
        playable = @getPlayableCards()
        if playable.length is 0
          @hand.drawFrom @round().deck
          setTimeout =>
            @round().nextTurn()
          , 400
        else
          @play playable[0]
    , 1000
