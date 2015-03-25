class RoundDeck

  events:
    'click': 'drawCard'

  render: ->
    @html require('views/round/deck')
    @

  drawCard: (e) =>
    if not @round.hasFinished() and @round.getCurrentPlayer().isHuman()
      @round.getCurrentPlayer().hand.drawFrom @round.deck
      @round.nextTurn()
