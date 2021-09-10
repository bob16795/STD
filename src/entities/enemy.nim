import gin/graphics

type
  Enemy* = object
    valid*: bool
    dest*: bool
    invis*: bool
    skin*: int
    pos*: Point
    pathLeft*: seq[Point]
    speed*: float
    hp*: int
    maxHp*: int

proc move*(e: var Enemy, dt: cuint): bool =
  if e.pathLeft.len == 0:
    return false
  if distance(e.pos, e.pathLeft[0]).int < (e.speed * dt.float).int:
    e.pathLeft = e.pathLeft[1..^1]
  if e.pathLeft.len == 0:
    return false
  var
    diffx = abs e.pos.X - e.pathLeft[0].X
    diffy = abs e.pos.Y - e.pathLeft[0].Y
  if (e.pos.X < e.pathLeft[0].X):
    e.pos.X += min((dt.float * e.speed).cint, diffx)
  else:
    e.pos.X -= min((dt.float * e.speed).cint, diffx)
  if (e.pos.Y < e.pathLeft[0].Y):
    e.pos.Y += min((dt.float * e.speed).cint, diffy)
  else:
    e.pos.Y -= min((dt.float * e.speed).cint, diffy)
  return true

proc getFuture*(e: Enemy, dt: int): Point =
  if e.pathLeft == @[]:
    return e.pos
  result = e.pos
  var
    diffx = abs result.X - e.pathLeft[0].X
    diffy = abs result.Y - e.pathLeft[0].Y
  if (result.X < e.pathLeft[0].X):
    result.X += min((dt.float * e.speed).cint, diffx)
  else:
    result.X -= min((dt.float * e.speed).cint, diffx)
  if (result.Y < e.pathLeft[0].Y):
    result.Y += min((dt.float * e.speed).cint, diffy)
  else:
    result.Y -= min((dt.float * e.speed).cint, diffy)


proc draw*(e: var Enemy, image: var Texture) =
  var texturex = 48'i32
  var texturey = 0'i32
  texturey += (e.skin * 16).cint
  if e.invis:
    texturex += 16
  draw(image, initRectangle(texturex, texturey, 16, 16), initRectangle(
      e.pos.X.cint, e.pos.Y.cint, 16, 16))
