ScoreCalculator = require __dirname + "/../score_calculator"
MatchScore = require __dirname + "/../match_score"

describe "ScoreCalculator", ->

    beforeEach ->
        @sc = new ScoreCalculator(__dirname + "/testFile.sco")
        @millis = 2000
        waitsFor ->
            @sc.done or @sc.err
        , "Parse operation did not complete in #{@millis} ms", @millis

    afterEach ->
        runs ->
            delete @sc


    describe "constructor", ->

        it "should return a calculator", ->
            runs ->
                expect(@sc).toBeDefined()

        it "should complete a parse operation", ->
            runs ->
                expect(@sc.err).toBeFalsy()

    describe "parse", ->

        it "saves a js object to property 'scores'", ->
            runs ->
                expect(@sc.scores).toBeDefined()

    describe "getMatches", ->
        beforeEach ->
            runs ->
                @sc.getMatches()

        it "saves a js object to property 'matches'", ->
            runs ->
                expect(@sc.matches).toBeDefined()

        it "returns the matches object", ->
            runs ->
                expect(@sc.getMatches()).toEqual @sc.matches

        it "contains an array of MatchScore objects", ->
            runs ->
                expect(@sc.matches[0].constructor).toBe MatchScore
            