import tower
import gin/graphics
import gin/input
import ../data/mapData

type
    Cursor* = object
        placeMode*: bool
        places*: Tower
        price*: int


proc draw*(c: var Cursor, image: var Texture, mapid: int) =
    if (c.placeMode and getMouseState().position.X < 400):
        c.places.pos = getMouseState().position - initPoint(8, 8)
        var
            tileX = ((c.places.pos.X + 8) / 16)
            tileY = ((c.places.pos.Y + 8) / 16)
        c.places.drawAlpha(image, not getMapAllowed(tileX, tileY, mapid))
