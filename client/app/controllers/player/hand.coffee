# Deck = require 'models/deck'
# Card = require 'models/card'
# Round = require 'models/round'

class PlayerHand

  events:
    'click .card': 'selectCard'

  className: 'player'

  constructor: ->
    super

    @player.hand.bind Deck.EVENT_UPDATE, @render
    @player.round().bind Round.EVENT_NEXT_TURN, @render

  selectCard: (e) ->
    if @player.isCurrentPlayer() and @player.isHuman() and not @player.round().hasFinished()
      target = $(e.currentTarget)

      cardId = target.attr 'data-card-id'

      @player.play(Card.find(cardId))

  render: =>
    current = @player.isCurrentPlayer()

    if current
      @el.addClass 'active'
    else
      @el.removeClass 'active'

    @html require('views/player/hand')
      player: @player
      transform: (i) ->
        deg = -10 + i * 2
        tranform = "
        -webkit-transform: rotate(#{deg}deg);
        -moz-transform: rotate(#{deg}deg);
        -ms-transform: rotate(#{deg}deg);
        -o-transform: rotate(#{deg}deg);
        transform: rotate(#{deg}deg);
        "
