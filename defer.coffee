class Defer
    constructor: (@action, args...)->
        @done = false
        @value = @action.apply(@self, args)
        @done = true

module.exports = Defer
