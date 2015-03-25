class RoundPile

  render: =>
    @html require('views/round/pile')
      pile: @round.pile
      transform: ->
        random = -10 + Math.floor Math.random()*30
        tranform = "
        -webkit-transform: rotate(#{random}deg);
        -moz-transform: rotate(#{random}deg);
        -ms-transform: rotate(#{random}deg);
        -o-transform: rotate(#{random}deg);
        transform: rotate(#{random}deg);
        "
    @
