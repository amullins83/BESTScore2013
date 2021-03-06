ScoreCalculator = require __dirname + "/../score_calculator"
MatchScore = require __dirname + "/../match_score"
Team = require __dirname + "/../team"

describe "ScoreCalculator", ->

    beforeEach ->
        @sc = new ScoreCalculator(__dirname + "/testFile.sco")
        @millis = 2000
        waitsFor ->
            @sc.done
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
                @sc_real = new ScoreCalculator __dirname + "/realGame.sco"

            waitsFor ->
                @sc_real.done
            , "Did not parse real game file", @millis

            runs ->
                @sc_real.getMatches()

        it "saves a js object to property 'matches'", ->
            runs ->
                expect(@sc.matches).toBeDefined()

        it "returns the matches object", ->
            runs ->
                expect(@sc.getMatches()).toEqual @sc.matches

        it "contains an array of MatchScore objects", ->
            runs ->
                expect(@sc.matches[0].constructor).toBe MatchScore

        it "only collects seeding phase matches", ->
            runs ->
                expect(@sc_real.matches.length).toBe 360
    
    describe "find match by team and round", ->
        beforeEach ->
            runs ->
                @sc.getMatches()

        it "returns matches[0] for team 3 round 1", ->
            runs ->
                expect(@sc.findMatchByTeamAndRound 3, 1).toEqual @sc.matches[0]

        it "returns matches[17] for team 1 round 6", ->
            runs ->
                expect(@sc.findMatchByTeamAndRound 1, 6).toEqual @sc.matches[17]

    describe "getInventory", ->
        beforeEach ->
            runs ->
                @sc_cpu = new ScoreCalculator __dirname + "/cpu32.sco"

            waitsFor ->
                @sc_cpu.done
            , "Failed to parse file", @millis

            runs ->
                @sc_cpu.getMatches()
                @sc_cpu.getInventory()

        it "defines an inventory object for each element of matches", ->
            runs ->
                expect(@sc_cpu.matches[@sc_cpu.matches.length - 1].inventory).toBeDefined()

        it "produces the correct inventory for the first round", ->
            runs ->
                expect(@sc_cpu.matches[1].inventory.NAND).toBe 120

        it "produces the correct inventory for the second match", ->
            runs ->
                expect(@sc_cpu.matches[7].inventory.ADDER).toEqual 2

        it "produces the correct inventory for the last match", ->
            runs ->
                expect(@sc_cpu.matches[8].inventory.CPU32Bit).toEqual 1

    describe "getScores", ->
        beforeEach ->
            runs ->
                @sc_cpu = new ScoreCalculator __dirname + "/cpu32.sco"

            waitsFor ->
                @sc_cpu.done
            , "Failed to parse file", @millis

            runs ->
                @sc_cpu.calculate()

        describe "agrees with the Tournament Software", ->

            it "for final total", ->
                runs ->
                    expect(@sc_cpu.teams[1].score).toBe 4505.6

            it "for first round", ->
                runs ->
                    expect(@sc_cpu.matches[1].total).toBe 960

            it "for second round", ->
                runs ->
                    expect(@sc_cpu.matches[7].total).toBe 1280

            it "for third round", ->
                runs ->
                    expect(@sc_cpu.matches[8].total).toBe 1984

    describe "agrees with Greg's Tournament results", ->

        beforeEach ->
            runs ->
                @sc_greg = new ScoreCalculator __dirname + "/greg.sco"

            waitsFor ->
                @sc_greg.done
            , "Failed to parse Greg file", @millis

            runs ->
                expect(@sc_greg.err).toBeFalsy()
                unless @sc_greg.err?
                    @sc_greg.calculate()

        it "for final total", ->
            runs ->
                unless @sc_greg.err?
                    expect(@sc_greg.teams[251].score).toBe 72

    describe "getTeamsSortedByHighScore", ->

        beforeEach ->
            runs ->
                @sc_real = new ScoreCalculator __dirname + "/realGame.sco"

            waitsFor ->
                @sc_real.done
            , "Failed to parse real game file", @millis

            runs ->
                expect(@sc_real.err).toBeFalsy()
                unless @sc_real.err?
                    @sc_real.calculate()
                    @sorted = @sc_real.getTeamsSortedByHighScore()

        it "gets an array", ->
            runs ->
                unless @sc_real.err?
                    expect(@sorted.constructor).toBe Array

        it "gets an array of teams", ->
            runs ->
                expect(@sorted[0].constructor).toBe Team

        it "sorts by high score", ->
            runs ->
                expect(@sorted[0].bestScore() > @sorted[1].bestScore()).toBe true

