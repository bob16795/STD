import os
import strutils
import streams

var output = newFileStream(paramStr(2), fmWrite)

for line in open(paramStr(1), fmRead).lines:
    var l = line.split("#")[0]
    if l == "": continue
    for s in l.split(","):
        var v = s.strip()
        output.write(v.parseInt().int32)
