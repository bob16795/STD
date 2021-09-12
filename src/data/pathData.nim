import streams
import gin/graphics
import gin/storage

var
    cpaths: seq[seq[Point]]

proc getPath*(id: int): seq[Point] =
    if cpaths == @[]:
        var f = newFileStream(getFullFilePath("content://paths.bin"), fmRead)
        var loop = true
        var paths: seq[seq[Point]]
        while loop:
            var path: seq[Point]
            var ammnt = f.readInt32()
            for pnt in 1..ammnt:
                path &= initPoint(f.readInt32().cint * 16, f.readInt32().cint * 16)
            paths &= path
            loop = not f.atEnd
        cpaths = paths
        f.close()
    return cpaths[id - 1]
