@Decks = new Mongo.Collection 'decks',
  transform: (data) ->
    new Deck data

DeckSchema = new SimpleSchema
  name:
    type: String
  playerId:
    type: String
    optional: true
  roundId:
    type: String

Decks.attachSchema DeckSchema

class Deck extends Model

  @_collection: Decks

  addCards: (cards) ->
    cards?.forEach (card) =>
      @addCard card

  addCard: (card) ->
    card?.update $set: deckId: @_id

  prependCard: (card) ->
    return unless card

    firstCard = @findFirstCard()

    rank = Math.ceil(firstCard?.rank or 0) - 1

    card.update
      $set:
        deckId: @_id
        rank: rank

  appendCard: (card) ->
    return unless card

    lastCard = @findLastCard()

    rank = Math.ceil(lastCard?.rank or 0) + 1

    card.update
      $set:
        deckId: @_id
        rank: rank

  findCards: (options) ->
    Cards.find deckId: @_id, options

  findOneCard: (options) ->
    Cards.findOne deckId: @_id, options

  countCards: (options) ->
    @findCards(options).count()

  findRound: ->
    Rounds.findOne(@roundId)

  findFirstCard: ->
    @findOneCard(sort: rank: 1)

  findLastCard: ->
    @findOneCard(sort: rank: -1)

  sort: ->
    cards.sort (a, b) ->
      if a.color is b.color
        if typeof a.type is 'string' or a.type > b.type then 1 else -1
      else
        if a.color > b.color then 1 else -1

    @save()

  shuffle: ->
    cards = @findCards().fetch()

    i = cards.length
    if i is 0 then return false

    while --i
      j = Math.floor(Math.random() * (i+1))
      [cards[i], cards[j]] = [cards[j], cards[i]]

    for card, i in cards
      card.update $set: rank: i + 1

  random: ->
    cards = @findCards().fetch()

    if cards.length
      i = Math.floor Math.random()*cards.length
      cards[i]
    else
      null

  contains: (card) ->
    card?.deckId is @_id

  mergeInto: (deck) ->
    if deck?.addCard?
      @findCards().fetch().forEach (card) ->
        deck.addCard card
