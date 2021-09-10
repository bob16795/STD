import gin
import gin/graphics
import gin/events
import gin/templates
import gin/storage
import gin/input
import map
import entities/entityManager
import event
import ui/uimanager, ui/uielements
import sound/sounds
import sugar
import lib/statemachine
import strformat
from sdl2 import Scancode
import os

Game:
  var
    image: Texture
    bg: Color
    em: EntityManager
    sm: SoundManager
    um: UIManager
    ms: MouseState
    pms: MouseState
    fsm: StateMachine

  template Initialize() =
    setWindowName("Sleep to Defend")
    setAppName("STD")
    setWindowSize(Point(X: 550, Y: 400))
    setDt(10)
    bg = initColor(0, 0, 0, 255)

  template drawLoading(pc: float, status: string): untyped =
    clearBuffer(bg)
    drawOutline(initRectangle(50, 500, 700, 20), initColor(255, 255, 255, 255))
    drawFill(initRectangle(50, 500, (7 * pc).cint, 20), initColor(255, 255,
            255, 255))
    if font.valid:
      var posx = (700 - font.sizeText($pc & status).X) / 2
      var pos = initPoint(posx.cint + 50, 400)
      font.renderText(pos, $pc.cint & "% " & status, initColor(255, 255,
              255, 255))


  template Setup(): untyped =
    setStatus("Load content files")

    font = initFontFace("content://poland.ttf", 14)
    em.lives = 100
    em.credits = 1
    sm = initSoundManager()
    um = initUIManager()

    var
      towerMenu = initUIGroup()
      roundMenu = initUIGroup()
      selectMenu = initUIGroup()

    var
      gamePausePress = initFlag(0, 1)
      pausePausePress = initFlag(0, 0)

      menu = initState(@[])
      game = initState(@[gamePausePress])   # 0
      pause = initState(@[pausePausePress]) # 1

    fsm = initStateMachine(@[menu, game, pause])

    sm.add("content://click.wav", "click", 255)
    sm.add("content://hover.wav", "hover", 255)

    image = loadTexture("content://sprites.bmp")
    eventEm = em.addr
    em.cursor.places = Tower(pos: Point(X: 30, Y: 30), sleepLeft: -1,
        makesKind: bkInvis)
    bg = initColor(0, 0, 0, 255)

    towerMenu.add(initUIButton(addr image, initRectangle(400, 0, 150, 25),
            (i: int) => upgradeTower(0), "Upgrade Speed"))
    towerMenu.add(initUIButton(addr image, initRectangle(400, 25, 150, 25),
            (i: int) => upgradeTower(1), "Upgrade Strength", () => true))
    towerMenu.add(initUIButton(addr image, initRectangle(400, 50, 150, 25),
            (i: int) => upgradeTower(2), "Upgrade Peirce"))
    towerMenu.add(initUIButton(addr image, initRectangle(400, 75, 75, 25),
            (i: int) => destroyTower(em), "Destroy"))
    towerMenu.add(initUIButton(addr image, initRectangle(475, 75, 75, 25),
            (i: int) => resetSelected(), "x"))
    roundMenu.add(initUIButton(addr image, initRectangle(400, 300, 75, 25),
            (i: int) => newTower(em, Tower(makesKind: bkInvis), 3), "Hollow (3)"))
    roundMenu.add(initUIButton(addr image, initRectangle(475, 300, 75, 25),
            (i: int) => newTower(em, Tower(fast: true, sleepLeft: -1,
                makesKind: bkInvis), 5), "FHollow (5)"))
    roundMenu.add(initUIButton(addr image, initRectangle(400, 325, 75, 25),
            (i: int) => newTower(em, Tower(makesKind: bkNorm), 1), "Normal (1)"))
    roundMenu.add(initUIButton(addr image, initRectangle(475, 325, 75, 25),
            (i: int) => newTower(em, Tower(fast: true, makesKind: bkNorm), 3),
                "FNormal (3)"))
    roundMenu.add(initUIButton(addr image, initRectangle(400, 275, 150, 25),
            (i: int) => newTower(em, Tower(support: true, makesKind: bkNorm),
                3), "Support (3)"))
    roundMenu.add(initUIButton(addr image, initRectangle(400, 350, 150, 25),
            (i: int) => nextRound(em), ">"))
    roundMenu.add(initUIButton(addr image, initRectangle(400, 375, 150, 25),
            (i: int) => restartGame(em), "Restart"))
    roundMenu.add(initUIText(initRectangle(400, 100, 150, 10), () =>
        &"lives: {em.lives}"))
    roundMenu.add(initUIText(initRectangle(400, 110, 150, 10), () =>
        &"round: {em.roundNum}"))
    roundMenu.add(initUIText(initRectangle(400, 120, 150, 10), () =>
        &"credits: {em.credits}"))
    selectMenu.add(initUIButton(addr image, initRectangle(400, 350, 150, 25),
            (i: int) => (em.selected = true), "Play"))
    selectMenu.add(initUIButton(addr image, initRectangle(475, 375, 75, 25),
            (i: int) => incMap(1), "Next"))
    selectMenu.add(initUIButton(addr image, initRectangle(400, 375, 75, 25),
            (i: int) => incMap(-1), "Prev"))
    selectMenu.add(initUIText(initRectangle(400, 100, 150, 10), () =>
        &"Map: {currentMap}"))
    selectMenu.add(initUIText(initRectangle(400, 110, 150, 10), () =>
        &"Rounds: {getRoundCount(em)}"))
    selectMenu.add(initUIText(initRectangle(400, 120, 150, 10), () =>
        &"Length: {getPathLength()}"))

    um.add(@[towerMenu,
             roundMenu,
             selectMenu])

    addSub(EVENT_DAMAGE, DamageEventProc)
    addSub(EVENT_CLICK, ClickEventProc)
    addSub(EVENT_ROUND, RoundEventProc)

  template Update(dt: cuint) =
    um.setActive(0, towerSelected())
    um.setActive(1, em.selected)
    um.setActive(2, not em.selected)
    discard um.update(sm)
    case fsm.currentState:
    of 0, 2:
      pms = ms
      ms = getMouseState()
      if (not pms.pressedButtons.contains(1) and ms.pressedButtons.contains(1)):
        queueEvent(Event(kind: EVENT_CLICK, data: EventData(data: @[
            ms.position.X.int, ms.position.Y.int])))
      if (not pms.pressedButtons.contains(3) and ms.pressedButtons.contains(3)):
        em.cursor.placeMode = false
        resetSelected()
      em.update(internal.eventBus, (dt.float / 10).cuint)
    of 1:
      pms = ms
      ms = getMouseState()
      if (not pms.pressedButtons.contains(1) and ms.pressedButtons.contains(1)):
        queueEvent(Event(kind: EVENT_CLICK, data: EventData(data: @[
            ms.position.X.int, ms.position.Y.int])))
      if (not pms.pressedButtons.contains(3) and ms.pressedButtons.contains(3)):
        em.cursor.placeMode = false
        resetSelected()
    else: discard

  template Draw(dt: cuint, ctx: GraphicsContext) =
    clearBuffer(bg)
    renderMap(image, currentMap)
    case fsm.currentState:
    of 0:
      em.draw(image)
    else:
      discard
    drawFill(initRectangle(400, 0, 150, 400), initColor(0, 0, 0, 255))
    draw(image, initRectangle(16, 32, 10, 7), initRectangle(400, 0, 150, 100))
    if em.selected:
      drawFill(initRectangle(400, 100, 150, 40), initColor(255, 255, 255, 255))
      drawFill(initRectangle(401, 101, 148, 38), initColor(0, 0, 0, 255))
    else:
      drawFill(initRectangle(400, 100, 150, 40), initColor(255, 255, 255, 255))
      drawFill(initRectangle(401, 101, 148, 38), initColor(0, 0, 0, 255))
    um.draw()

  template Close() =
    echo "close"
