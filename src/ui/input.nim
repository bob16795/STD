import gin/input
import tables
from sdl2 import Scancode

type
    InputEvent* = proc(): void
    InputManager* = object
        actions*: Table[Scancode, InputEvent]

var kbState, prevKBState: KeyboardState

proc update*(im: InputManager) =
    prevKBState = kbState
    kbState = getKeyBoardState()
    for key in prevKBState.pressedkeys:
        if not kbState.contains(key) and im.actions.contains(key):
            im.actions[key]()

proc add*(im: var InputManager, code: Scancode, ev: InputEvent) =
    im.actions[code] = ev