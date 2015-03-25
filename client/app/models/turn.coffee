class Turn

  # @configure 'Turn', 'status'
  #
  # @belongsTo 'round', 'models/round'
  # @belongsTo 'player', 'models/player'

  @STATUS_INIT = 'init'
  @STATUS_START = 'start'
  @STATUS_FINISH = 'finish'

  @defaults:
    status: Turn.STATUS_INIT

  start: ->
    @status = Turn.STATUS_START
    @save()

    if @player().isAi()
      @player().aiPlay()

  finish: ->
    @status = Turn.STATUS_FINISH
    @save()
