FieldResults = require __dirname + "/field_results"

class MatchScore
    constructor: (@raw_match)->
        @MatchNumber = parseInt @raw_match.I32.Val
        @TeamNumber = parseInt @raw_match.U32.Val
        @DQ = @raw_match.Boolean.Val == '1'
        @Tiebreak = @raw_match.U16[0].Val == '1'
        @CurrentMatchPhase = ["Seeding", "WildCard", "Semifinal", "Final"][parseInt @raw_match.U16[1].Val]
        @FieldResults = new FieldResults @raw_match.Cluster[1].Cluster

    @values:
        AND:        10
        OR:         10
        NOT:        10
        NAND:        8
        MUX:        80
        ADDER:      60
        DECODER:    40
        DLATCH:     60
        REGISTER:   90
        InstDec:    60
        InstMux:   120
        InstAdd:    90
        Mem8Bit:    90
        Mem32Bit:  420
        CPU8Bit:   512
        CPU32Bit: 1024

    @requirements:
        MUX:
            Normal:
                AND: 2
                OR:  1
                NOT: 1
            NAND: 3
        ADDER:
            Normal:
                AND: 1
                OR:  1
                NOT: 1
            NAND: 2
        DECODER:
            Normal:
                AND: 1
                NOT: 1
            NAND: 2
        DLATCH:
            Normal:
                AND: 1
                OR:  1
                NOT: 1
            NAND: 1
        REGISTER:
            DLATCH: 1
        InstDec:
            DECODER: 1
        InstMux:
            MUX: 1
        InstAdd:
            ADDER: 1
        Mem8Bit:
            DLATCH: 1
        Mem32Bit:
            DLATCH: 4
            DECODER: 1

    scoreWithInventory: (@inventory)->
        @total = 0
        @scoreGates()
        @scoreICs()
        @scoreCPU()

    scoreGates: =>
        @scoreNormalGate gate for gate in ["AND", "OR", "NOT"]
        @scoreNandGate()

    scoreICs: =>
        @scoreIC IC for IC in ["MUX", "ADDER", "DECODER", "DLATCH"]

    scoreCPU: =>

    scoreNormalGate: (gate)=>
        numGates = 4*@FieldResults[gate].P.U
        numGates += 2*@FieldResults[gate].P.L
        numGates += 2*@FieldResults[gate].N.U
        numGates += @FieldResults[gate].N.L
        @total += MatchScore.values[gate]*numGates

    scoreNandGate: =>
        numGates = 2*@FieldResults.NAND.P
        numGates += @FieldResults.NAND.N
        @total += MatchScore.values.NAND*numGates

    scoreIC: (IC)=>
        numICs = @timesMetRequirements IC

        unless @FieldResults[IC].Lower
            numICs *= 2

        @total += MatchScore.values[IC]*numICs

    timesMetRequirements: (unit)=>
        timesMet = 0
        reqs = MatchScore.requirements[unit]
        if reqs.Normal? # unit is an IC
            metNormalReqs = true
            while metNormalReqs
                for gate of reqs.Normal
                    unless @FieldResults[unit][gate] >= reqs.Normal[gate]
                        metNormalReqs = false
                        break
                if metNormalReqs and @inventoryContains reqs.Normal
                    timesMet += 1
                    for gate of reqs.Normal
                        @inventory[gate] -= reqs.Normal[gate]
            metNandReqs = true
            while metNandReqs
                unless @FieldResults[unit][NAND] >= reqs.NAND
                    metNandReqs = false
                if metNandReqs and @inventoryContains reqs
                    timesMet += 1
                    @inventory[NAND] -= reqs.NAND
        else #unit is a CPU component
            timesMet = 0

        return timesMet

    inventoryContains: (quantities)=>
        for req of quantities
            continue if req is "Normal"
            return false if @inventory[req] < quantities[req]
        return true

module.exports = MatchScore
