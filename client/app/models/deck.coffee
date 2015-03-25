class Deck

  # @configure 'Deck', '_cards'

  @EVENT_UPDATE       : 'update'
  @EVENT_CLEARED      : 'cleared'
  @EVENT_SORTED       : 'sorted'
  @EVENT_SHUFFLED     : 'shuffled'
  @EVENT_CARD_ADDED   : 'card-added'
  @EVENT_CARD_DROPPED : 'card-dropped'
  @EVENT_EMPTY        : 'empty'

  @defaults:
    _cards: []

  clear: =>
    @_cards = []
    @trigger @constructor.EVENT_CLEARED
    @trigger @constructor.EVENT_UPDATE
    @save()

  add: (cardOrArray) ->
    if cardOrArray instanceof Card
      @_cards.push cardOrArray
      @trigger @constructor.EVENT_CARD_ADDED, cardOrArray
      @trigger @constructor.EVENT_UPDATE
    else
      for card in cardOrArray
        @add card

    @save()

  all: ->
    @_cards.clone()

  first: ->
    @_cards.first()

  last: ->
    @_cards.last()

  count: ->
    @_cards.count()

  select: (check) ->
    return @all() unless check and typeof check is 'function'
    result = []
    for card in @_cards
      result.push card if check(card)
    result

  sort: ->
    @_cards.sort (a, b) ->
      if a.color is b.color
        if typeof a.type is 'string' or a.type > b.type then 1 else -1
      else
        if a.color > b.color then 1 else -1

    @trigger @constructor.EVENT_SORTED
    @trigger @constructor.EVENT_UPDATE
    @save()

  shuffle: ->
    i = @_cards.length
    if i is 0 then return false

    while --i
      j = Math.floor(Math.random() * (i+1))
      [@_cards[i], @_cards[j]] = [@_cards[j], @_cards[i]]
    true

    @trigger @constructor.EVENT_SHUFFLED
    @trigger @constructor.EVENT_UPDATE
    @save()

  random: ->
    if @_cards and @_cards.length > 0
      i = Math.floor Math.random()*@_cards.length
      @_cards[i]
    else
      null

  contains: (card) ->
    for possibleCard in @_cards
      if card.eql possibleCard
        return true
        break
    false

  drawFrom: (deck, card) ->
    deck._pushTo this, card

  _pushTo: (deck, card) ->
    found = false

    card = card or @last()

    for c, i in @_cards
      if card.eql c
        found = i
        break

    if found is false
      null
    else
      card = @_cards[found]
      deck.add card
      @_cards.remove found

      @trigger @constructor.EVENT_CARD_DROPPED, card
      @save()

      if @_cards.isEmpty() then @trigger @constructor.EVENT_EMPTY
      card

  mergeInto: (deck) ->
    for card in @_cards
      deck.add card

    @reset()
    @save()
