class Round

  # @configure 'Round', '_status', '_dir', '_players', '_turns', 'pile', 'deck'
  #
  # @belongsTo 'game', 'models/game'
  # @belongsTo 'winner', 'models/player', 'winner_id'
  #
  # @extend Spine.Model.Local

  @STATUS_INIT = 'init'
  @STATUS_START = 'start'
  @STATUS_FINISH = 'finish'

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

  @EVENT_NEXT_TURN = 'next-turn'
  @EVENT_DIRECTION_CHANGED = 'dir-change'
  @EVENT_END_OF_ROUND = 'round-ended'
  @EVENT_PLAYER_ADDED = 'player-added'

  @defaults:
    _players: []
    _turns: []
    _status: @STATUS_INIT
    deck: ->
      deck = new Deck()
      deck.save()
      deck
    pile: ->
      deck = new Deck()
      deck.save()
      deck
    _dir: 1

  start: ->
    @_checkFinished()

    if @_players.length < @constructor.MINIMUM_PLAYERS
      throw new Error @constructor.ERROR_NOT_ENOUGH_PLAYERS

    @deck.bind Deck.EVENT_EMPTY, @recycle

    @_initDecks()

    @_status = @constructor.STATUS_START
    @save()

    @nextTurn()

  finish: ->
    @_status = @constructor.STATUS_FINISH
    @save()
    @deck.unbind Deck.EVENT_EMPTY, @recycle

  _initDecks: ->
    @_checkFinished()

    if Card.all().length is 0
      throw new Error @constructor.ERROR_NO_CARDS

    @deck.add Card.all()
    @deck.shuffle()

    for player in @getPlayers()
      for i in [0...@constructor.DEFAULTS_NR_OF_CARDS]
        player.hand.drawFrom @deck

    @pile.drawFrom @deck

  recycle: =>
    temp = new Deck()
    temp.drawFrom @pile

    @pile.mergeInto @deck
    @deck.shuffle()
    temp.mergeInto @pile

  invite: (user) ->
    if @hasStarted()
      throw new Error @constructor.ERROR_ALREADY_STARTED
    for player in @_players
      if player.user_id is user.id
        throw new Error @constructor.ERROR_USER_ALREADY_JOINED

    player = new Player
      round_id: @id
      user_id: user.id
      name: user.name

    player.save()

    @addPlayer player

  addPlayer: (player) ->
    if @hasStarted()
      throw new Error @constructor.ERROR_ALREADY_STARTED
    if @_players.count() >= @constructor.MAXIMUM_PLAYERS
      throw new Error @constructor.ERROR_MAXIMUM_PLAYERS
    if @findPlayer player.id
      throw new Error @constructor.ERROR_PLAYER_ALREADY_JOINED
    else
      player.round_id = @id
      player.save()
      @_players.push player

      @trigger @constructor.EVENT_PLAYER_ADDED, player
      player

  getPlayers: ->
    @_players.clone()

  findPlayer: (playerOrId) ->
    id = playerOrId?.id or playerOrId

    for player in @_players
      if player.id is id
        return player
    false

  getCurrentPlayer: ->
    if @getCurrentTurn()
      @findPlayer @getCurrentTurn().player_id or null
    else
      @getNextPlayer()

  swapDir: ->
    @_checkFinished()
    @_dir *= -1
    @trigger @constructor.EVENT_DIRECTION_CHANGED, @_dir
    @save()

  getStatus: ->
    @_status

  hasStarted: ->
    @_status isnt @constructor.STATUS_INIT

  hasFinished: ->
    @_status is @constructor.STATUS_FINISH

  _checkFinished: ->
    if @hasFinished() then throw new Error @constructor.ERROR_ALREADY_FINISHED

  nextTurn: ->
    @_checkFinished()

    if not @_checkWin()
      nextPlayer = @getNextPlayer()

      @getCurrentTurn()?.finish()

      @_turns.push turn = new Turn
        player_id: nextPlayer.id
        round_id: @id

      turn.save()

      @trigger @constructor.EVENT_NEXT_TURN, turn

      turn.start()

      turn

  _checkWin: ->
    @_checkFinished()

    current = @getCurrentPlayer()
    if current?.hand?.count() is 0
      @winner_id = current.id
      @finish()
      @trigger @constructor.EVENT_END_OF_ROUND, current
      true
    else
      false

  getCurrentTurn: ->
    @_turns.last()

  getNextPlayer: ->
    @_checkFinished()

    if @_turns.length is 0
      @_players[0]
    else
      turn = @getCurrentTurn()

      pos = @getPlayerPosition turn.player_id

      if pos is false
        @_players[0]
      else
        nextPos = pos + @_dir

        if nextPos < 0
          @_players.last()
        else if nextPos >= @_players.length
          @_players.first()
        else
          @_players[nextPos]

  getPlayerPosition: (playerOrId) ->
    id = playerOrId?.id or playerOrId

    for player, i in @_players
      if id is player.id
        return i
    false

  getPlayersStartingFrom: (playerOrId) ->
    id = playerOrId?.id or playerOrId

    later = []
    result = []

    for player, i in @_players
      if id is player.id or result.length isnt 0
        result.push player
      else
        later.push player

    result.concat later
