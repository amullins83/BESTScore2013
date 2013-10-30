class Team
    constructor: (@number)->
        @score = 0
        @rounds = {}
        @bonusApplied = false

    numRounds: =>
        n = 0
        n++ for round of @rounds
        n

    numBonusRounds: =>
        n = 0
        for round of @rounds
            n++ if @rounds[round].bonus
        n

    addRound: (round)=>
        @score += round.total
        @rounds[round.MatchNumber] =
            matchNumber: round.MatchNumber
            score: round.total
            bonus: round.Bonus

    removeRound: (matchNumber)=>
        if @rounds[matchNumber]?
            @score -= @rounds[matchNumber].score
            delete @rounds[matchNumber]
        else
            return false

    applyBonus: =>
        unless @bonusApplied
            maxBonus = 0.1
            @bonusApplied = true
            @score *= 1 + maxBonus * @numBonusRounds()/@numRounds()

module.exports = Team
