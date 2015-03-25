# abilities = require 'uno/data/abilities'

class Card

  # @configure 'Card', 'color', 'type', 'points', 'abilities'

  @colors = ['yellow','green','blue','red']

  @types = [1,2,3,4,5,6,7,8,9,'turn','skip','draw2']

  @createAll: ->
    for card in @all()
      card.destroy()

    for color in @colors
      for type in @types
        card = new Card
          color: color
          type: type

        if typeof type is 'string'
          card.abilities = [type]

        card.save()

    return

    for i in [1..2]
      card = new Card
        color: 'black'
        type: 'draw4'
        abilities: ['draw4']
      card.save()

    for i in [1..2]
      card = new Card
        color: 'black'
        type: 'change'
        abilities: ['change']
      card.save()

  @getAbility: (name = 'default') ->
    abilities = require 'uno/data/abilities'

    abilities[name] or (r,cb) -> cb()

  run: (round, cb) ->
    if not @abilities?
      cb() if cb
    else
      Card.getAbility(@abilities[0])(round, cb)

  isBlack: ->
    @type is 'draw4' or @type is 'change'

  getPoints: ->
    if @isBlack()
      50
    else
      if typeof @type is 'string' then 20 else @type
