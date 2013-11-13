Team = require __dirname + "/../team"

class Match
    constructor: (round, team, inventory, score, bonus)->
        @MatchNumber = round
        @TeamNumber = team
        @inventory = inventory
        @total = score
        @Bonus = bonus

describe "Team", ->

    beforeEach ->
        @t = new Team 100
        @t.addRound new Match 1, 100, {}, 100, true
        @t.addRound new Match 2, 100, {},  50, false

    describe "constructor", ->

        it "makes a Team object", ->
            expect(@t.constructor).toBe Team

        it "sets score to 0", ->
            expect((new Team(100)).score).toBe 0

        it "creates a rounds hash", ->
            expect(@t.rounds.constructor).toBe Object

    describe "numRounds", ->
        it "returs the number of rounds", ->
            n = 0
            n++ for round of @t.rounds
            expect(@t.numRounds()).toBe n

    describe "numBonusRounds", ->

        it "returns the right number", ->
            n = 0
            n++ if(round.bonus) for key, round of @t.rounds
            expect(@t.numBonusRounds()).toBe n 

    describe "addRound", ->

        it "adds a round to the round hash", ->
            expect(@t.numRounds()).toBe 2

        it "increments the score", ->
            expect(@t.score).toBe 150

    describe "removeRound", ->

        it "deletes the selected round", ->
            @t.removeRound 1
            expect(@t.rounds[1]).not.toBeDefined()

        it "decrements the score", ->
            @t.removeRound 1
            expect(@t.score).toBe 50

    describe "applyBonus", ->

        beforeEach ->
            @t.applyBonus()

        it "adds the correct amount to score", ->
            expect(@t.score).toBe 157.5

        it "only works once", ->
            @t.applyBonus()
            expect(@t.score).toBe 157.5
    
    describe "bestRound", ->

        it "returns the round number of the highest scoring round", ->
            expect(@t.bestRound()).toBe '1'

    describe "bestScore", ->

        it "returns the score of the highest scoring round", ->
            expect(@t.bestScore()).toBe 100

        it "doesn't break when the score is 0", ->
            too_bad = new Team 200
            too_bad.addRound new Match 1, 200, {}, 0, false
            expect(too_bad.bestScore()).toBe 0
