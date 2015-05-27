@Rounds = new Mongo.Collection 'rounds',
  transform: (data) ->
    new Round data

Rounds.before.insert (userId, doc) ->
  doc.createdBy ?= userId
  doc.updatedBy ?= userId

Rounds.before.update (userId, doc) ->
  doc.updatedBy = userId

class Round extends Model

  @_collection: Rounds

  @MINIMUM_PLAYERS = 3
  @MAXIMUM_PLAYERS = 8
  @DEFAULTS_NR_OF_CARDS = 7

  @ERROR_NOT_ENOUGH_PLAYERS = "Not enought players to start the round"
  @ERROR_MAXIMUM_PLAYERS = "This round is already at its maximum of players"
  @ERROR_NO_CARDS = "There are no cards yet to deal"
  @ERROR_ALREADY_STARTED = "Users cannot be added after initialization of the round"
  @ERROR_ALREADY_FINISHED = "This round is already over"
  @ERROR_PLAYER_ALREADY_JOINED = "The player is already in this round"
  @ERROR_USER_ALREADY_JOINED = "The user is already in this round"

  finish: ->
    @update $set: finishedAt: new Date
    @hasFinished()

  _initDecks: ->
    @_checkFinished()

    pileId = Decks.insert
      name: 'pile'
      roundId: @_id

    deckId = Decks.insert
      name: 'deck'
      roundId: @_id

    if @countCards() is 0
      throw new Error @constructor.ERROR_NO_CARDS

    pileCard = Cards.findOne
      roundId: @_id
      deckId: null
    ,
      sort: rank: 1

    pileCard.addToDeck pileId

    cards = Cards.find(
      roundId: @_id
      deckId: null
    ).fetch()

    cards.forEach (card) ->
      card.addToDeck deckId

  recycle: =>
    temp = new Deck()
    temp.drawFrom @pile

    @pile.mergeInto @deck
    @deck.shuffle()
    temp.mergeInto @pile

  getCurrentPlayer: ->
    if turn = @getCurrentTurn()
      turn.findPlayer()
    else
      @getNextPlayer()

  swapDir: ->
    @dir *= -1
    @update $set: dir: @dir

  _checkFinished: ->
    if @hasFinished() then throw new Error @constructor.ERROR_ALREADY_FINISHED

  getCurrentTurn: ->
    return if not @currentTurnId

    Turns.findOne @currentTurnId

  nextTurn: ->
    @_checkFinished()

    if not @_checkWin()
      nextPlayer = @getNextPlayer()

      @getCurrentTurn()?.finish()

      @currentTurnId = Turns.insert
        roundId: @_id
        playerId: nextPlayer._id

      @update $set: currentTurnId: @currentTurnId

      turn = @getCurrentTurn()
      turn?.start()
      turn

  _checkWin: ->
    @_checkFinished()

    current = @getCurrentPlayer()

    if not current
      false
    else
      deck = Decks.findOne
        name: 'hand'
        playerId: current._id

      finished = not deck?.countCards()

      if finished
        @update $set: winnerId: current._id
        @finish()

      finished

  getNextPlayer: ->
    @_checkFinished()

    queryOptions = sort: rank: @dir

    findFirst = =>
      @findPlayer queryOptions

    if @countTurns() is 0
      findFirst()
    else
      turn = @getCurrentTurn()

      rank = turn.findPlayer().rank

      playerQuery =
        roundId: @_id
        rank: $gt: rank

      if @dir is -1
        playerQuery.rank = $lt: rank

      nextPlayer = Players.findOne playerQuery, queryOptions

      nextPlayer or findFirst()

  canJoin: (userId) ->
    return false if @hasStarted()

    # AI players have no userId
    return true if not userId

    player = Players.findOne
      userId: userId
      roundId: @_id

    not player

  addPlayer: (data = {}) ->
    if not @canJoin data.userId
      throw new Meteor.Error "CANT_JOIN"
      return

    defaultPlayerData =
      roundId: @_id
      gameId: @gameId

    if not data.name
      data.name = Meteor.users
        .findOne data.userId
        .emails?[0].address

    lastPlayer = @findPlayer
      sort: rank: -1

    lastRank = lastPlayer?.rank or 0

    data.rank = Math.ceil lastRank + 1

    newData = _.extend {}, data, defaultPlayerData

    Players.insert newData

  start: ->
    round = this

    if not @canStart()
      throw new Meteor.Error "NO_PLAYERS_YET"
    else
      shuffleArray = (array) ->
        i = array.length - 1
        while i > 0
          j = Math.floor(Math.random() * (i + 1))
          temp = array[i]
          array[i] = array[j]
          array[j] = temp
          i--
        array

      types = shuffleArray CardTypes.find().fetch()

      types.forEach (cardType, i) ->
        Cards.insert
          roundId: round._id
          gameId: round.gameId
          cardTypeId: cardType._id
          color: cardType.color
          type: cardType.type
          abilities: cardType.abilities
          rank: i + 1

      aiPlayerCount = @constructor.MINIMUM_PLAYERS - @countPlayers()

      if aiPlayerCount
        for i in [1..aiPlayerCount]
          @addPlayer
            name: "Computer #{i}"

      @findPlayers().fetch().forEach (player) ->
        player.init()

      @_initDecks()

      @update $set: startedAt: Date.now()

      @nextTurn()

  canStart: (userId) ->
    if userId and @createdBy isnt userId
      return false

    Boolean @countPlayers()

  hasStarted: ->
    Boolean @startedAt

  hasFinished: ->
    Boolean @finishedAt

  findPlayer: (options) ->
    Players.findOne roundId: @_id, options

  findPlayers: (options) ->
    Players.find roundId: @_id, options

  countPlayers: (options) ->
    @findPlayers(options).count()

  findTurns: (options) ->
    Turns.find roundId: @_id, options

  countTurns: (options) ->
    @findTurns(options).count()

  findCards: (options) ->
    Cards.find roundId: @_id, options

  countCards: (options) ->
    @findCards(options).count()
