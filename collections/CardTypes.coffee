@CardTypes = new Mongo.Collection 'cardtypes',
  transform: (data) ->
    new CardType data

class CardType extends Model

  @_collection: CardTypes
