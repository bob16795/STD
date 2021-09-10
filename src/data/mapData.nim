import gin/graphics
import gin/storage
import strutils
import strformat

var
    cMap = -1
    mapData: string
proc getMap*(p: Point, id: int): Rectangle =
    if cMap != id:
        mapData = readFile(getFullFilePath(&"content://map{id}.map"))
        cMap = id
    case mapData.split("\n")[p.Y][p.X]:
    of '0':
        return initRectangle(0, 0, 16, 16)
    of '1':
        return initRectangle(16, 0, 16, 16)
    of '2':
        return initRectangle(32, 0, 16, 16)
    of 'H':
        return initRectangle(80, 0, 16, 16)
    else:
        return initRectangle(0, 0, 16, 16)

proc getMapPreview*(p: Point, id: int): Rectangle =
    if cMap != id:
        mapData = readFile(getFullFilePath(&"content://map{id}.map"))
        cMap = id
    case mapData.split("\n")[p.Y][p.X]:
    of '0':
        return initRectangle(37, 16, 2, 2)
    of '1':
        return initRectangle(39, 16, 2, 2)
    of '2':
        return initRectangle(41, 16, 2, 2)
    else:
        return initRectangle(37, 16, 2, 2)

proc getMapAllowed*(x, y: float, id: int): bool =
    if cMap != id:
        mapData = readFile(getFullFilePath(&"content://map{id}.map"))
        cMap = id
    try:
        if (x <= 0.5) or (y <= 0.5):
            return false
        return mapData.split("\n")[(y - 0.5f).int][(x - 0.5f).int] in ['0'] and
            mapData.split("\n")[(y + 0.5f).int][(x - 0.5f).int] in ['0'] and
            mapData.split("\n")[(y - 0.5f).int][(x + 0.5f).int] in ['0'] and
            mapData.split("\n")[(y + 0.5f).int][(x + 0.5f).int] in ['0'] and
            mapData.split("\n")[(y).int][(x).int] in ['0']
    except IndexDefect:
        return false
