ScoreCalculator = require __dirname + "/../score_calculator"

describe "ScoreCalculator", ->
    
    describe "Parse", ->
        it "should be callable", ->
            runs ->
                ScoreCalculator.parse __dirname + "/testFile.sco"

            runs ->
                expect true
    
    describe "Score", ->
        it "should be callable", ->
            runs ->
                ScoreCalculator.score __dirname + "/testFile.sco"
            
            runs ->
                expect true
