FieldResults = require __dirname + "/field_results"

class MatchScore
    constructor: (@raw_match)->
        @MatchNumber = parseInt @raw_match.I32.Val
        @TeamNumber = parseInt @raw_match.U32.Val
        @DQ = @raw_match.Boolean.Val == '1'
        @Tiebreak = @raw_match.U16[0].Val == '1'
        @CurrentMatchPhase = ["Seeding", "WildCard", "Semifinal", "Final"][parseInt @raw_match.U16[1].Val]
        @FieldResults = new FieldResults @raw_match.Cluster[1].Cluster
        @Bonus = @FieldResults.Bonus

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
            DLATCH:   1
        InstDec:
            DECODER:  1
        InstMux:
            MUX:      1
        InstAdd:
            ADDER:    1
        Mem8Bit:
            DLATCH:   1
        Mem32Bit:
            DLATCH:   4
            DECODER:  1
        CPU32Bit:
            DLATCH:   7
            DECODER:  2
            ADDER:    1
            MUX:      1
        CPU8Bit:
            DLATCH:   4
            DECODER:  1
            ADDER:    1
            MUX:      1

    @cpuFieldRequirements:
        CPU32Bit:
            InstDec:  1
            InstAdd:  1
            InstMux:  1
            REGISTER: 3
            AddDec:   1
            Mem8Bit:  4
        CPU8Bit:
            InstDec:  1
            InstAdd:  1
            InstMux:  1
            REGISTER: 3
            Mem8Bit:  1
        Mem32Bit:
            Mem8Bit:  4
            AddDec:   1
        Mem8Bit:
            Mem8Bit:  1
        InstAdd:
            InstAdd:  1
        InstMux:
            InstMux:  1
        InstDec:
            InstDec:  1
        REGISTER:
            REGISTER: 1

    scoreWithInventory: (@inventory)->
        @total = 0
        @scoreGates()
        @scoreICs()
        @scoreCPU()
        @total

    scoreGates: =>
        @scoreNormalGate gate for gate in ["AND", "OR", "NOT"]
        @scoreNandGate()

    scoreICs: =>
        @scoreIC IC for IC in ["MUX", "ADDER", "DECODER", "DLATCH"]

    scoreCPU: =>
        if @FieldResults.CPU?
            @scoreCPUcomponent component for component in ["CPU32Bit", "CPU8Bit", "Mem32Bit", "Mem8Bit", "REGISTER", "InstDec", "InstMux", "InstAdd"]

    scoreCPUcomponent: (component)=>
        numComponents = @timesMetRequirements component
        @total += MatchScore.values[component]*numComponents

    scoreNormalGate: (gate)=>
        numGates = 4*@FieldResults[gate].P.U
        numGates += 2*@FieldResults[gate].P.L
        numGates += 2*@FieldResults[gate].N.U
        numGates += @FieldResults[gate].N.L
        @addToInventory gate, numGates
        @total += MatchScore.values[gate]*numGates

    scoreNandGate: =>
        numGates = 6*@FieldResults.NAND.P
        numGates += 3*@FieldResults.NAND.N
        @addToInventory "NAND", numGates
        @total += MatchScore.values.NAND*numGates

    scoreIC: (IC)=>
        numICs = @timesMetRequirements IC
        @total += MatchScore.values[IC]*numICs

    timesMetRequirements: (unit)=>
        reqs = MatchScore.requirements[unit]
        if reqs.Normal? # unit is an IC
            return @timesMetRequirementsIC unit
        else #unit is a CPU component
            return @timesMetRequirementsCPU unit

    timesMetRequirementsIC: (unit)=>
        timesMet = 0
        reqs = MatchScore.requirements[unit]
        metNormalReqs = true
        while metNormalReqs
            for gate of reqs.Normal
                unless ((@FieldResults[unit][gate] >= reqs.Normal[gate]) and @inventoryContains reqs.Normal)
                    metNormalReqs = false
                    break
            if metNormalReqs
                for gate of reqs.Normal
                    @inventory[gate] -= reqs.Normal[gate]
                    @FieldResults[unit][gate] -= reqs.Normal[gate]
                if @FieldResults[unit].Lower
                    number = 1
                else
                    number = 2
                @addToInventory unit, number
                timesMet += number
        metNandReqs = true
        while metNandReqs
            unless ((@FieldResults[unit].NAND >= reqs.NAND) and @inventoryContains reqs)
                metNandReqs = false
                break
            if metNandReqs
                @inventory.NAND -= reqs.NAND
                @FieldResults[unit].NAND -= reqs.NAND
                if @FieldResults[unit].Lower
                    number = 1
                else
                    number = 2
                @addToInventory unit, number
                timesMet += number
        return timesMet

    timesMetRequirementsCPU: (unit)=>
        timesMet = 0
        metReqs = true
        fieldReqs = MatchScore.cpuFieldRequirements[unit]
        inventoryReqs = MatchScore.requirements[unit]
        while metReqs
            for subReq of fieldReqs
                unless ((@FieldResults.CPU[subReq] >= fieldReqs[subReq]) and @inventoryContains inventoryReqs)
                    metReqs = false
                    break
            if metReqs
                timesMet += 1
                for subReq of fieldReqs
                    @FieldResults.CPU[subReq] -= fieldReqs[subReq]
                for subReq of inventoryReqs
                    @inventory[subReq] -= inventoryReqs[subReq]
                @addToInventory unit, 1
        return timesMet

    inventoryContains: (quantities)=>
        for req of quantities
            return false unless @inventory[req]? and @inventory[req] >= quantities[req] or req is "Normal"
        return true

    addToInventory: (unit, number)=>
        unless @inventory?
            @inventory = {}
        if @inventory[unit]?
            @inventory[unit] += number
        else
            @inventory[unit] = number

module.exports = MatchScore
