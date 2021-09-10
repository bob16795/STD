import gin/graphics
import data/mapData

proc renderMap*(image: var Texture, id: int) =
  for x in 0..24:
    for y in 0..24:
      draw(image, getMap(initPoint(x.cint, y.cint), id), initRectangle(16 *
          x.cint, 16 * y.cint, 16, 16))

proc preview*(image: var Texture, id: int) =
  for x in 0..24:
    for y in 0..24:
      draw(image, getMapPreview(initPoint(x.cint, y.cint), id), initRectangle(
          16 * x.cint, 16 * y.cint, 16, 16))
