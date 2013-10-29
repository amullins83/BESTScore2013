fs = require "fs"
XML = require "xml-simple"
MatchScore = require __dirname + "/match_score"

class ScoreCalculator
    constructor: (@scoreFile)->
        @done = false
        @err = false
        @parse()

    parse: ->
        fs.readFile @scoreFile, (@err, file)=>
            unless @err
                XML.parse file, @calculateOrError
            else
                @done = true

    calculateOrError: (@err, @scores)=>
        unless @err
            @calculate()
        else
            console.dir @err
        @done = true

    calculate: =>
        @getMatches()
        @getInventory()
        @getScores()

    getMatches: =>
        raw_matches = @scores.Array.Cluster
        @matches = []
        for raw_match in raw_matches
            @matches.push new MatchScore raw_match
        @matches

    getInventory: =>

    getScores: =>

module.exports = ScoreCalculator
