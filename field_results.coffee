class FieldResults
    constructor: (@raw_results)->
        @AND = @getGate 0

        @OR = @getGate 1

        @NOT = @getGate 2

        @NAND = @getNand()

        @MUX = @getIC 4

        @ADDER = @getIC 5

        @DECODER = @getIC 6

        @DLATCH = @getIC 7

        @Bonus = @raw_results[8].Boolean.Val == '1'

        @CPU = @getCPU()

    getGate: (index)=>
        P:
            U: @parseRawResult index, 0
            L: @parseRawResult index, 2
        N:
            U: @parseRawResult index, 1
            L: @parseRawResult index, 3

    getNand: =>
        P: @parseRawResult 3, 0
        N: @parseRawResult 3, 1

    getIC: (index)=>
        Lower: @raw_results[index].Boolean.Val == '1'
        AND:   @parseRawResult index, 0
        OR:    @parseRawResult index, 1
        NOT:   @parseRawResult index, 2
        NAND:  @parseRawResult index, 3

    getCPU: =>
        REGISTER: @parseRawResult 9, 0
        InstAdd:  @parseRawResult 9, 1
        InstMux:  @parseRawResult 9, 2
        InstDec:  @parseRawResult 9, 3
        Mem8Bit:  @parseRawResult 9, 4
        AddDec:   @parseRawResult 9, 5

    parseRawResult: (index, sub)=>
        parseInt @raw_results[index].I32[sub].Val

module.exports = FieldResults
