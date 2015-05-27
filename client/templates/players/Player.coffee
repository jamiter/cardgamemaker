Template.Player.helpers
  playerDeck: ->
    if @userId is Meteor.userId() then 'player-deck'

  className: ->
    classes = ["position#{@rank-1}"]

    if @isCurrentPlayer()
      classes.push 'active'

    classes.join ' '
