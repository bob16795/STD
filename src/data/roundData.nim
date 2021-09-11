import ../entities/rounds
import gin/storage
import streams
import pathData

var roundData: seq[Round]

proc readRounds*(id: int): seq[Round] =
    if roundData == @[]:
        var f = newFileStream(getFullFilePath("content://rounds.bin"), fmRead)
        var loop = true
        while loop:
            var r = Round()
            r.running = true
            r.path = getPath(id)
            r.start = getPath(id)[0]
            r.enemies &= (Invis, 0)
            var length = f.readInt32()
            for i in 0..<length:
                var
                    kind = f.readInt32().EnemyKind
                    ammnt = f.readInt32()
                    time = f.readInt32().int
                for num in 0..<ammnt:
                    r.enemies &= (kind, time)
            roundData &= r
            loop = not f.atEnd
    return roundData
