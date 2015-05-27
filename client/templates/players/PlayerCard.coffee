Template.PlayerCard.onCreated ->
  @cardType = @data.findCardType()

Template.PlayerCard.helpers
  type: ->
    if Template.parentData().userId is Meteor.userId()
      Template.instance().cardType?.type
    else
      'UNO'
  color: ->
    if Template.parentData().userId is Meteor.userId()
      Template.instance().cardType?.color or 'black'
    else
      'black'

Template.PlayerCard.events
  'click': (event) ->
    if not Template.parentData().isCurrentPlayer()
      alert 'You are not the current player'
      return

    Template.parentData().play this
