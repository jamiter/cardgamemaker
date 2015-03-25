# defaultOptions = require('uno/data/defaults').game

class Game

  # @configure 'Game', 'name', '_users', '_rounds', '_options', 'ai_count'

  @ERROR_USER_ALREADY_JOINED = "The user already joined this game"

  @defaults:
    # name: defaultOptions.name
    # ai_count: defaultOptions.ai_count
    _rounds: []
    _users: []

  getRounds: ->
    @_rounds.clone()

  getUsers: ->
    @_users.clone()

  newRound: ->
    @_rounds.last()?.finish()

    if @_users.length + @ai_count < Round.MINIMUM_PLAYERS
      throw new Error Round.ERROR_NOT_ENOUGH_PLAYERS

    round = new Round game_id: @id
    round.save()

    @_rounds.push round

    for user in @_users
      round.invite user

    if @ai_count > 0
      for i in [1..@ai_count]
        player = new Player
          _ai: true
          name: "Computer #{i}"
        player.save()

        round.addPlayer player

    round.one Round.EVENT_END_OF_ROUND, @scoreboard

    round

  scoreboard: (round) =>
    scoreboard = "The winner is #{round.winner().name}!\n\nScores:\n"

    for player in round.getPlayers()
      score = 0
      for card in player.hand.all()
        score += card.getPoints()
      scoreboard += "#{player.name}: #{score}\n"

    alert scoreboard

  invite: (user) ->
    if @_rounds.length > 0 and @_rounds.last().getStatus() isnt Round.STATUS_INIT
      throw new Error Round.ERROR_ALREADY_STARTED

    find = User.select (item) =>
      item.game_id is @id and item.user_id is user.id

    if @findUser user
      throw new Error @constructor.ERROR_USER_ALREADY_JOINED

    @_users.push user

    @trigger 'user-added', user
    user

  findUser: (userOrId) ->
    return false if not userOrId?

    id = userOrId.id or userOrId

    for user in @_users
      if user.id is id
        return user
    false
