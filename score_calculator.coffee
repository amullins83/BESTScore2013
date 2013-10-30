fs = require "fs"
XML = require "xml-simple"
MatchScore = require __dirname + "/match_score"
Team = require __dirname + "/team"

copy = (thing)->
    val = {}
    val[prop] = thing[prop] for prop of thing
    return val

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
        @teams = {}
        for raw_match, index in raw_matches
            this_match = new MatchScore raw_match
            @matches.push this_match
            num = this_match.TeamNumber
            unless num of @teams
                @teams[num] = new Team num
        @matches

    getInventory: =>
        for match in @matches
            round = match.MatchNumber
            team = match.TeamNumber
            if round == 1
                match.scoreWithInventory {}
            else
                match.scoreWithInventory copy(@findMatchByTeamBeforeRound(team, round).inventory)
            @teams[team].addRound match

    getScores: =>
        @getHighScoreMatch()
        @getTeamTotals()

    getHighScoreMatch: =>
        @highScoreMatchIndex = 0
        for match, index in @matches
            @highScoreMatchIndex = index if match.total > @matches[@highScoreMatchIndex].total

    getTeamTotals: =>
        for num, team of @teams
            team.applyBonus()

    findMatchByTeamBeforeRound: (team, round)=>
        while round > 0
            round -= 1
            match = @findMatchByTeamAndRound team, round
            return match if match?
        return null

    findMatchByTeamAndRound: (team, round)=>
        for match in @matches
            return match if(match.MatchNumber == round and match.TeamNumber == team)
        return null

module.exports = ScoreCalculator
