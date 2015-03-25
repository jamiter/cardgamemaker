# PlayerHand = require 'controllers/player/hand'
# RoundDeck = require 'controllers/round/deck'
# RoundPile = require 'controllers/round/pile'

class App

  events:
    'keyup input.username': 'checkStart'

  constructor: ->
    super

    Card.createAll()

    @start()

    @render()

  render: ->
    if not @game?
      @html require('views/game/start')
    else
      @el.empty()
      round = @game.getRounds().last()

      for player, i in round.getPlayers()
        hand = new PlayerHand player: player
        hand.render()
        hand.el.addClass 'player-deck' if not player.isAi() and player.user().current
        hand.el.addClass "position#{i}"
        @append hand.el

      @deck = new RoundDeck round: round
      @pile = new RoundPile round: round

      @append @deck.render().el
      @append @pile.render().el

  checkStart: (e) =>
    if e.keyCode is 13
      target = $(e.currentTarget)
      name = target.val().trim()
      if name isnt ""
        @start name

  start: (name = "You") ->

    u1 = new User
      name: name
      current: true
    u1.save()

    @game = u1.createGame 'Real game'

    @game.newRound().start()

    @render()
