class @Model
  constructor: (data = {}) ->
    _.extend this, data

  update: (options) ->
    @constructor._collection?.update _id: @_id, options
