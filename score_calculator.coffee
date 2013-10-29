fs = require "fs"
XML = require "xml-simple"

class ScoreCalculator
    @parse: (scoreFile, callback)->
        fs.readFile scoreFile, (err, file)->
            unless err
                XML.parse file, callback

    @score: (scoreFile)->
        @parse scoreFile, @calculate

    @calculate: (err, scores)->
        unless err
            console.dir scores

module.exports = ScoreCalculator
