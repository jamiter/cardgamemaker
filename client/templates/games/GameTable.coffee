Template.GameTable.helpers
  players: ->
    [
        status: 2
        name: 'Player 1'
        points: 2
        isHuman: true
        cards: [
          type: 1
          color: 'red'
        ,
          type: 'draw'
          color: 'yellow'
        ]
    ]
