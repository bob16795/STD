import gin/graphics
import gin/input
import ../graphics/graphics as localGraphics
import uisprites
import ../sound/sounds

type
  UIAction* = proc(i: int)
  UIUpdate* = proc(): string
  UIElementKind* = enum
    UIButton,
    UIText,
    UIGroup
  UIElement* = object of RootObj
    focused*: bool
    isActive*: bool
    bounds*: Rectangle
    case kind*: UIElementKind
    of UIButton:
      isDisabled*: proc(): bool
      buttonAction*: UIAction
      buttonText*: string
      buttonHasSprite*: bool
      buttonSprite*: Sprite
      buttonNormal, buttonClicked, buttonDisabled, buttonFocused: UISprite
    of UIText:
      textText*: string
      textUpdate*: UIUpdate
    of UIGroup:
      groupElements: seq[UIElement]

var
  font*: FontFace

proc initUIGroup*(): UIElement =
  result.isActive = true
  result = UIElement(kind: UIGroup)

proc add*(group: var UIElement, e: UIElement) =
  group.groupElements.add(e)

proc initUIButton*(texture: ptr Texture, bounds: Rectangle,
        action: UIAction = nil, text = "", disableProc: proc(): bool = nil,
            sprite: Sprite = Sprite()): UIElement =
  result = UIElement(kind: UIButton)

  result.isActive = true
  result.bounds = bounds
  result.isDisabled = disableProc
  result.buttonNormal = initUiSprite(texture, initRectangle(32, 16, 5, 5),
          initRectangle(34, 18, 1, 1))
  result.buttonDisabled = initUiSprite(texture, initRectangle(37, 26, 5, 5),
          initRectangle(39, 28, 1, 1))
  if action != nil:
    result.buttonAction = action
  result.buttonText = text
  if sprite.texture != nil:
    result.buttonSprite = sprite
    result.buttonHasSprite = true


proc initUIText*(bounds: Rectangle, text = ""): UIElement =
  result = UIElement(kind: UIText)

  result.isActive = true
  result.bounds = bounds
  result.textText = text

proc initUIText*(bounds: Rectangle, update: UIUpdate): UIElement =
  result = UIElement(kind: UIText)

  result.isActive = true
  result.bounds = bounds
  result.textUpdate = update

proc checkHover*(e: var UIElement, ms, pms: MouseState): bool =
  if not e.isActive:
    return false
  if e.kind == UIButton and e.isDisabled != nil and e.isDisabled():
    return false
  if (e.bounds.X < (ms.position.X / SCALE).int and e.bounds.X +
          e.bounds.Width > (ms.position.X / SCALE).int) and
      (e.bounds.Y < (ms.position.Y / SCALE).int and e.bounds.Y +
              e.bounds.Height > (ms.position.Y / SCALE).int):
      return true
  if e.kind == UIGroup:
    for i in 0..<e.groupElements.len:
      if e.groupElements[i].checkHover(ms, pms):
        return true

proc update*(e: var UIElement, ms, pms: MouseState, sm: SoundManager): bool =
  if not e.isActive:
    return false
  case e.kind:
  of UIButton:
    if (e.bounds.X < (ms.position.X / SCALE).int and e.bounds.X +
            e.bounds.Width > (ms.position.X / SCALE).int) and
        (e.bounds.Y < (ms.position.Y / SCALE).int and e.bounds.Y +
                e.bounds.Height > (ms.position.Y / SCALE).int):
        e.focused = true
        for j in 1..8:
          if (not ms.pressedButtons.contains(j.uint8) and
                  pms.pressedButtons.contains(j.uint8)):
            if e.isDisabled == nil or not e.isDisabled():
              sm.play("click")
              e.buttonAction(j)
        if ms.pressedButtons != @[]:
          return true
    return false
  of UIText:
    if e.textUpdate != nil:
      e.textText = e.textUpdate()
  of UIGroup:
    for i in 0..<e.groupElements.len:
      if e.groupElements[i].update(ms, pms, sm):
        return true
  return false

proc draw*(element: var UIElement) =
  if not element.isActive:
    return
  case element.kind:
  of UIButton:
    if element.isDisabled != nil:
      if (element.isDisabled()):
        element.buttonDisabled.draw(element.bounds)
      else:
        element.buttonNormal.draw(element.bounds)
    else:
      element.buttonNormal.draw(element.bounds)
    if (element.buttonHasSprite):
      element.buttonSprite.draw(element.bounds.location + initPoint(2, 2),
          @[RT_ANY], 0, element.bounds.size - initPoint(4, 4))
    if (element.buttonText != ""):
      var
        centerx: cint = (element.bounds.X.cint * SCALE + ((
                element.bounds.Width * SCALE - sizeText(font,
                element.buttonText).X) / 2).cint)
        centery: cint = (element.bounds.Y.cint * SCALE +
                element.bounds.Height * SCALE - ((sizeText(font,
                element.buttonText).Y) * 3 / 2).cint)
      renderText(font, initPoint(centerx.cint, centery.cint),
              element.buttonText, initColor(255, 255, 255, 255))
  of UIText:
    if (element.textText != ""):
      var
        centerx: cint = (element.bounds.X.cint * SCALE + ((
                element.bounds.Width * SCALE - sizeText(font,
                element.textText).X) / 2).cint)
        centery: cint = (element.bounds.Y.cint * SCALE +
                element.bounds.Height * SCALE - ((sizeText(font,
                element.textText).Y) / 2).cint)
      renderText(font, initPoint(centerx.cint, centery.cint),
              element.textText, initColor(255, 255, 255, 255))
  of UIGroup:
    for i in 0..<element.groupElements.len:
      element.groupElements[i].draw()
