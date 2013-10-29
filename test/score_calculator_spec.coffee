ScoreCalculator = require __dirname + "/../score_calculator"

describe "ScoreCalculator", ->
    beforeEach ->
        @sc = new ScoreCalculator(__dirname + "/testFile.sco")
        @millis = 2000

    afterEach ->
        delete @sc

    describe "constructor", ->
        it "should return a calculator", ->
            expect(@sc).toBeDefined()

        it "should complete a parse operation", ->
            waitsFor( ->
                @sc.done or @sc.err
            , "Parse operation did not complete in #{@millis} ms", @millis)

            runs ->
                expect(@sc.err).toBeFalsy()

    describe "parse", ->
        it "saves a js object to property 'scores'", ->
            waitsFor( ->
                @sc.done or @sc.err
            , "Parse operation did not complete in #{@millis} ms", @millis)

            runs ->
                expect(@sc.scores).toBeDefined()
            