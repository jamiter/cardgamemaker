@Cards = new Mongo.Collection 'cards',
  transform: (data) ->
    new Card data

CardSchema = new SimpleSchema
  cardTypeId:
    type: String
  roundId:
    type: String
  deckId:
    type: String
    optional: true
  abilities:
    type: [String]
    optional: true
  rank:
    type: Number

# Cards.attachSchema CardSchema

class Card extends Model

  @_collection: Cards

  @getAbility: (name = 'default') ->
    CardAbilities[name] or (r,cb) -> cb?()

  findCardType: ->
    CardTypes.findOne @cardTypeId

  addToDeck: (deckId) ->
    @update $set: deckId: deckId

  run: (round) ->
    @abilities?.forEach (ability) =>
      @constructor.getAbility(ability)(round)

  isBlack: ->
    @type in ['draw4', 'change']

  getPoints: ->
    if @isBlack()
      50
    else
      if typeof @type is 'string' then 20 else @type
