Meteor.startup ->
  cardTypeCount = CardTypes.find().count()

  console.log "#{cardTypeCount} card types"

  if cardTypeCount is 0
    colors = ['yellow','green','blue','red']

    types = [1,2,3,4,5,6,7,8,9,'turn','skip','draw2']

    colors.forEach (color) ->
      types.forEach (type) ->
        cardType =
          color: color
          type: type

        if typeof type is 'string'
          cardType.abilities = [type]

        CardTypes.insert cardType

    # for i in [1..2]
    #   card = new Card
    #     color: 'black'
    #     type: 'draw4'
    #     abilities: ['draw4']
    #   card.save()
    #
    # for i in [1..2]
    #   card = new Card
    #     color: 'black'
    #     type: 'change'
    #     abilities: ['change']
    #   card.save()
