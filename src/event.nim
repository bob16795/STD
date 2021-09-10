import gin/events
import gin/graphics
import entities/entityManager

const
  EVENT_DAMAGE* = 1
  EVENT_CLICK* = 2
  EVENT_ROUND* = 3

var
  eventEm*: ptr EntityManager

proc DamageEventProc*(data: EventData) =
  eventEm[].lives -= data.data[0]

proc ClickEventProc*(data: EventData) =
  var pos = Point(X: data.data[0].cint, Y: data.data[1].cint)
  if (pos.X < 400):
    var lol = false
    for t in 0..<eventEm[].towers.len:
      if eventEm[].towers[t].hitBox.contains(pos):
        eventEm[].towers[t].click()
        lol = true
    if not lol:
      placeTower(eventEm[])
      resetSelected()

proc RoundEventProc*(data: EventData) =
  for e in 0..<eventEm.towers.len:
    eventEm.towers[e].endRound(eventEm[])
  eventEm.credits += 1
