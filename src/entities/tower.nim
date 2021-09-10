import gin/graphics
import enemy
import math

type
  BulletKind* = enum
    bkNorm,
    bkInvis
  Tower* = object
    fast*: bool
    makesKind*: BulletKind
    pos*: Point
    angle: float
    sleepLeft*: int
    sleepCallback*: proc(e: var Tower)
    speed*: int
    cooldown*: int
    support*: bool
    range*: int
    dmg*: int
  Bullet* = object
    kind*: BulletKind
    dest*: bool
    valid*: bool
    dmg*: int
    posx*: float
    posy*: float
    velocityx*: float
    velocityy*: float

var
  selected*: ptr Tower

proc getFocus*(e: var Tower, enemies: seq[Enemy]): Enemy =
  if e.sleepLeft != -1: return
  for enemy in enemies:
    if enemy.invis and e.makesKind == bkInvis:
      if enemy.pos.distance(e.pos).int <= e.range + 8:
        return enemy
    elif not enemy.invis and e.makesKind == bkNorm:
      if enemy.pos.distance(e.pos).int <= e.range + 8:
        return enemy

proc shoot*(e: var Tower, dt: cuint, enemies: seq[Enemy]): Bullet =
  if e.support: return
  if not e.getFocus(enemies).valid:
    return
  e.cooldown -= dt.int
  if e.cooldown < 0:
    if e.fast:
      e.cooldown += (50 / (e.speed + 1)).int
    else:
      e.cooldown += (100 / (e.speed + 1)).int
    var
      velx = sin(e.angle)
      vely = cos(e.angle)
    return Bullet(valid: true, posx: e.pos.X.float + 5, posy: e.pos.Y.float + 5,
        velocityx: velx, velocityy: vely, kind: e.makesKind, dmg: e.dmg)


proc update*(e: var Tower, enemies: seq[Enemy]) =
  if e.support: return
  if not e.getFocus(enemies).valid:
    return
  if enemies == @[]:
    return
  if e.sleepLeft == -1:
    var
      focus = e.getFocus(enemies)
      time = (e.pos.distance(focus.pos) / 5).int
      x = focus.getFuture(time).X - e.pos.X
      y = focus.getFuture(time).Y - e.pos.Y
    if (y != 0):
      e.angle = arctan(x / y)
    else:
      e.angle = PI
    if y < 0:
      e.angle -= PI
  else:
    e.angle = PI


proc draw*(e: var Tower, image: var Texture) =
  var texturey = 16'i32
  if e.makesKind == bkInvis:
    texturey += 16
  if e.fast:
    texturey += 32
  if e.support:
    texturey = 80
  if e.sleepLeft >= 0:
    draw(image, initRectangle(0, texturey, 16, 16), initRectangle(e.pos.X.cint,
        e.pos.Y.cint, 16, 16), initColor(0, 0, 0, 128), 180 + (e.angle /
            PI * -180))
  else:
    draw(image, initRectangle(0, texturey, 16, 16), initRectangle(e.pos.X.cint,
        e.pos.Y.cint, 16, 16), 180 + (e.angle / PI * -180))

proc drawTop*(e: var Tower, image: var Texture) =
  if selected == e.addr:
    if e.sleepLeft != -1:
      draw(image, initRectangle(16, 16, 16, 16), initRectangle(
          e.pos.X.cint + 8 - (e.range + 8).cint, e.pos.Y.cint + 8 - (e.range +
              8).cint, 2 * (e.range + 8).cint, 2 * (e.range + 8).cint),
                  initColor(255, 0, 0, 128))
    else:
      draw(image, initRectangle(16, 16, 16, 16), initRectangle(
          e.pos.X.cint + 8 - (e.range + 8).cint, e.pos.Y.cint + 8 - (e.range +
              8).cint, 2 * (e.range + 8).cint, 2 * (e.range + 8).cint),
                  initColor(255, 255, 255, 128))
    e.draw(image)

proc drawAlpha*(e: var Tower, image: var Texture, bad: bool) =
  var c = initColor(255, 255, 255, 128)
  if bad:
    c = initColor(255, 0, 0, 128)
  draw(image, initRectangle(16, 16, 16, 16), initRectangle(
      e.pos.X.cint + 8 - (e.range + 8).cint, e.pos.Y.cint + 8 - (e.range +
          8).cint, 2 * (e.range + 8).cint, 2 * (e.range + 8).cint), c)
  var texturey = 16'i32
  if e.makesKind == bkInvis:
    texturey += 16
  if e.fast:
    texturey += 32
  if e.support:
    texturey = 80
  draw(image, initRectangle(0, texturey, 16, 16), initRectangle(e.pos.X.cint,
      e.pos.Y.cint, 16, 16), initColor(0, 0, 0, 128), 180 + (e.angle / PI * -180))

proc draw*(e: var Bullet, image: var Texture) =
  case e.kind:
  of bkNorm:
    draw(image, initRectangle(32, 21, 5, 5), initRectangle(e.posx.cint,
        e.posy.cint, 5, 5))
  of bkInvis:
    draw(image, initRectangle(32, 26, 5, 5), initRectangle(e.posx.cint,
        e.posy.cint, 5, 5))


proc update*(e: var Bullet, dt: cuint): bool =
  e.posx += (e.velocityx * dt.float * 5)
  e.posy += (e.velocityy * dt.float * 5)
  if e.posx < 0 or
     e.posy < 0 or
     e.posx > 400 or
     e.posy > 400:
    return true

proc click*(t: var Tower) =
  selected = t.addr

proc hitBox*(e: Tower): Rectangle =
  return initRectangle(e.pos.X.cint - 8, e.pos.Y.cint - 8, 32, 32)

proc resetSelected*() =
  selected = nil

proc towerSelected*(): bool =
  return selected != nil

proc finalizeSpeedUpgrade(e: var Tower) =
  e.speed += 1

proc finalizeStrengthUpgrade(e: var Tower) =
  e.dmg += 1

proc finalizeRangeUpgrade(e: var Tower) =
  e.range += 32

proc upgradeTower*(id: int) =
  if selected.sleepLeft >= 0:
    return
  if id == 0:
    selected.sleepLeft = 0
    selected.sleepCallback = finalizeSpeedUpgrade
  if id == 1:
    selected.sleepLeft = 2
    selected.sleepCallback = finalizeStrengthUpgrade
  if id == 2:
    selected.sleepLeft = 1
    selected.sleepCallback = finalizeRangeUpgrade
