fs = require "fs"
XML = require "xml-simple"
MatchScore = require __dirname + "/match_score"

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
        @teams = []
        for raw_match, index in raw_matches
            @matches.push new MatchScore raw_match
            @teams.push @matches[index].TeamNumber
        @matches

    getInventory: =>
        for match in @matches
            round = match.MatchNumber
            team = match.TeamNumber
            if round == 1
                match.scoreWithInventory {}
            else
                match.scoreWithInventory copy(@findMatchByTeamBeforeRound(team, round).inventory)

    getScores: =>
        @getHighScoreMatch()
        @getTeamTotals()

    getHighScoreMatch: =>
        @highScoreMatchIndex = 0
        for match, index in @matches
            @highScoreMatchIndex = index if match.total > @matches[@highScoreMatchIndex].total

    getTeamTotals: =>
        @teamScore = {}
        for team in @teams
            @teamScore[team] = 0
            for match in @matches
                if match.TeamNumber == team
                    @teamScore[team] += match.total
            @applyBonus team

    applyBonus: (team)=>
        maxBonus = 0.1
        totalRounds = 0
        bonusRounds = 0
        for match in @matches
            if match.TeamNumber == team
                totalRounds += 1
                if match.Bonus
                    bonusRounds += 1
        if totalRounds > 0
            @teamScore[team] *= 1 + maxBonus*bonusRounds/totalRounds

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
