ScoreCalculator = require __dirname + "/../score_calculator"
FieldResults = require __dirname + "/../field_results"
MatchScore = require __dirname + "/../match_score"

describe "MatchScore", ->

    describe "constructor", ->
        beforeEach ->
            @sc = new ScoreCalculator __dirname + "/testFile.sco"
            waitsFor ->
                @sc.done or @sc.err
            , "timeout while parsing test file", 2000

            runs ->
                @ms = new MatchScore @sc.scores.Array.Cluster[17]
        
        afterEach ->
            delete @ms
            delete @sc

        it "returns an Object", ->
            runs -> 
                expect(@ms).toBeDefined()

        it "contains a FieldResults object", ->
            runs ->
                expect(@ms.FieldResults.constructor).toBe FieldResults

    describe "score with inventory", ->

        beforeEach ->
            @sc = new ScoreCalculator __dirname + "/testFile.sco"
            waitsFor ->
                @sc.done or @sc.err
            , "timeout while parsing test file", 2000

        afterEach ->
            delete @ms
            delete @sc

        it "scores a set of gates correctly", ->
            runs ->
                @ms = new MatchScore @sc.scores.Array.Cluster[0]
                expect(@ms.scoreWithInventory {}).toEqual 88

        describe "scores a set of ICs correctly", ->

            beforeEach ->
                runs ->
                    @ms = new MatchScore @sc.scores.Array.Cluster[7]

            afterEach ->
                delete @ms

            it "when inventory is insufficient", ->
                runs ->
                    expect(@ms.scoreWithInventory {}).toEqual 0

            it "when NAND inventory is equal to requirement", ->
                runs ->
                    expect(@ms.scoreWithInventory {NAND: 2}).toEqual 60

            it "when Normal inventory is equal to requirement, but NAND isn't", ->
                runs ->
                    expect(@ms.scoreWithInventory {AND: 2, OR: 1, NOT: 1}).toEqual 0

            it "when NAND inventory is higher than requirement", ->
                runs ->
                    expect(@ms.scoreWithInventory {NAND: 6}).toEqual 60

        describe "scores an 8-bit CPU correctly", ->

            beforeEach ->
                runs ->
                    @ms = new MatchScore @sc.scores.Array.Cluster[17]

            afterEach ->
                delete @ms

            it "when inventory is insufficient", ->
                runs ->
                    expect(@ms.scoreWithInventory {}).toEqual 0

            it "when inventory equals requirement", ->
                runs ->
                    expect(@ms.scoreWithInventory { DLATCH: 4, DECODER: 2, MUX: 1, ADDER: 1 }).toEqual 512

            it "when inventory exceeds requirement", ->
                runs ->
                    expect(@ms.scoreWithInventory { DLATCH: 16, DECODER: 8, MUX: 10, ADDER: 10 }).toEqual 512

        describe "adjusts inventory correctly", ->

            it "when making gates", ->
                runs ->
                    @ms = new MatchScore @sc.scores.Array.Cluster[0]
                    @ms.scoreWithInventory {}
                    expect(@ms.inventory.NAND).toBe 6

            describe "when making ICs", ->

                beforeEach ->
                    runs ->
                    @ms = new MatchScore @sc.scores.Array.Cluster[7]
                    @ms.scoreWithInventory { NAND: 2 }

                afterEach ->
                    delete @ms

                it "reduces the number of gates", ->
                    expect(@ms.inventory.NAND).toBe 0

                it "increases the number of ICs", ->
                    expect(@ms.inventory.ADDER).toBe 1

            describe "when making CPUs", ->

                beforeEach ->
                    runs ->
                    @ms = new MatchScore @sc.scores.Array.Cluster[17]
                    @ms.scoreWithInventory { DLATCH: 4, DECODER: 2, MUX: 1, ADDER: 1 }

                afterEach ->
                    delete @ms

                it "reduces the number of ICs", ->
                    expect(@ms.inventory.DLATCH).toBe 0

                it "increases the number of CPUs", ->
                    expect(@ms.inventory.CPU8Bit).toBe 1