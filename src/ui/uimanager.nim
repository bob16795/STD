import gin/input
import uielements
import ../lib/templates
import ../sound/sounds

type
    UIManager* = object
        elements: seq[UIElement]
var pms, ms: MouseState
var hover, phover: bool

proc initUIManager*(): UIManager =
    discard

proc add*(um: var UIManager, e: UIElement) =
    um.elements.add(e)

proc add*(um: var UIManager, e: seq[UIElement]) =
    um.elements.add(e)

proc setActive*(um: var UIManager, id: int, to: bool) =
    um.elements[id].isActive = to

proc setPopup*(um: var UIManager, id: int, to: bool) =
    um.elements[id].hasPopupAbove = to

proc update*(um: var UIManager, sm: SoundManager): bool =
    pms = ms
    ms = getMouseState()
    phover = hover
    hover = false
    ifor e, um.elements:
        hover = hover or checkHover(e, ms, pms)
    if (hover and not phover):
        sm.play("hover")
    elif (not hover and phover):
        sm.play("releasehover")
    ifor e, um.elements:
        if e.update(ms, pms, sm): return true
    return false

proc draw*(um: var UIManager) =
    ifor e, um.elements:
        e.draw()
