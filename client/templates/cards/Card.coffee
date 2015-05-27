Template.Card.onCreated ->
  @cardType = @data.findCardType()

Template.Card.helpers
  color: ->
    Template.instance().cardType?.color or 'black'
  type: ->
    Template.instance().cardType?.type
