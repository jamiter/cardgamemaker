class User

  # @configure 'User', 'name', 'email', 'current', 'prefs'
  #
  # @extend Spine.Model.Local

  createGame: (name = "New game") ->
    Game = require 'models/game'
    game = new Game
      created_by: @id
      name: name
    game.invite this
    game.save()

    game
