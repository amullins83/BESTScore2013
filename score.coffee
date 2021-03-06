ScoreCalculator = require __dirname + "/score_calculator"

sc = new ScoreCalculator process.argv[2]

twiddle = ->
    if not sc.done and not sc.err
        setTimeout twiddle, 1000
    else if not sc.err
        for team in sc.teams
            console.log "Team Number #{team} scored #{sc.teamScore[team]} points"
    else
        console.log "An error occurred while parsing #{process.argv[2]}"

twiddle()
