import gin/graphics
import ../graphics/hitbox
import ../data/roundData
import ../data/pathData
import ../data/mapData
import gin/events
import enemy
import tower
import rounds
import cursor
import sequtils

export enemy
export tower
export rounds
export cursor

var
  currentMap*: int = 1

type
  EntityManager* = object
    roundNum*: int
    round*: Round
    enemies*: seq[Enemy]
    towers*: seq[Tower]
    bullets*: seq[Bullet]
    cursor*: Cursor
    lives*: int
    credits*: int
    selected*: bool

proc add*(em: var EntityManager, e: Enemy) =
  if e.valid:
    em.enemies &= e

proc add*(em: var EntityManager, e: Bullet) =
  if e.valid:
    em.bullets &= e

proc add*(em: var EntityManager, e: Tower) =
  em.towers &= e

proc checkCollision*(e: var Enemy, bullets: var seq[Bullet]) =
  for b in 0..<bullets.len:
    if (initHitBox(initRectangle(bullets[b].posx.cint, bullets[b].posy.cint, 5,
        5), hkRectangle).checkCollision(initHitBox(initRectangle(e.pos.X,
            e.pos.Y, 16, 16), hkRectangle))):
      bullets[b].dest = true
      if e.invis and bullets[b].kind == bkInvis:
        e.hp -= bullets[b].dmg
      elif not e.invis and bullets[b].kind == bkNorm:
        e.hp -= bullets[b].dmg

proc update*(em: var EntityManager, eb: var EventBus, dt: cuint) =
  if em.enemies.len != 0 or em.round.enemies.len != 1:
    em.add(em.round.update(dt, eb))
    for e in 0..<em.enemies.len:
      checkCollision(em.enemies[e], em.bullets)
      if not em.enemies[e].move(dt):
        eb.add(Event(kind: 1, data: EventData(data: @[em.enemies[e].hp])))
        em.enemies[e].hp = 0
    for e in 0..<em.bullets.len:
      if not em.bullets[e].dest:
        em.bullets[e].dest = em.bullets[e].update(dt)
    em.bullets = em.bullets.filter(proc (x: Bullet): bool = not x.dest)
    em.enemies = em.enemies.filter(proc (x: Enemy): bool = x.hp > 0)
    for e in 0..<em.towers.len:
      em.towers[e].update(em.enemies)
      em.add(em.towers[e].shoot(dt, em.enemies))
  elif em.round.running and em.round.enemies.len == 1:
    em.round.running = false
    em.bullets = @[]
    eb.add(Event(kind: 3, data: EventData(data: @[])))

proc draw*(em: var EntityManager, image: var Texture) =
  for e in 0..<em.bullets.len:
    em.bullets[e].draw(image)
  for e in 0..<em.enemies.len:
    em.enemies[e].draw(image)
  for e in 0..<em.towers.len:
    em.towers[e].draw(image)
  for e in 0..<em.towers.len:
    em.towers[e].drawTop(image)
  em.cursor.draw(image, currentMap)

proc destroyTower*(em: var EntityManager) =
  for e in 0..<em.towers.len:
    if em.towers[e].addr == selected:
      em.towers.del(e)
      resetSelected()
      break

proc getPathLength*(): int =
  var last = getPath(currentMap)[0]
  var total: float
  for point in getPath(currentMap):
    total += last.distance(point)
    last = point
  return total.int

proc nextRound*(em: var EntityManager) =
  if not em.round.running:
    em.round = readRounds(currentMap)[em.roundNum]
    em.roundNum += 1
    em.roundNum = min(readRounds(currentMap).len - 1, em.roundNum)

proc getRoundCount*(em: var EntityManager): int = readRounds(currentMap).len

proc newTower*(em: var EntityManager, t: Tower, price: int) =
  if em.credits >= price:
    em.cursor.places = t
    em.cursor.places.sleepLeft = -1
    em.cursor.places.dmg = 1
    em.cursor.places.range = 64
    em.cursor.price = price
    em.cursor.placeMode = not em.cursor.placeMode

proc placeTower*(em: var EntityManager) =
  if (em.cursor.placeMode):
    var
      tileX = ((em.cursor.places.pos.X + 8) / 16)
      tileY = ((em.cursor.places.pos.Y + 8) / 16)
    if not getMapAllowed(tileX, tileY, currentMap): return
    em.credits -= em.cursor.price
    em.towers &= em.cursor.places
  em.cursor.placeMode = false

proc endRound*(e: var Tower, em: var EntityManager) =
  if e.sleepLeft > -1:
    e.sleepLeft -= 1
    if e.sleepLeft <= -1:
      e.sleepCallback(e)
  else:
    if e.support:
      em.credits += e.speed

proc incMap*(i: int) =
  currentMap = (currentMap + i).clamp(1, 5)

proc restartGame*(em: var EntityManager) =
  em.credits = 1
  em.bullets = @[]
  em.enemies = @[]
  em.towers = @[]
  em.round = Round()
  em.roundNum = 0
  em.selected = false
  resetSelected()
  em.cursor.placeMode = false
