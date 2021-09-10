import gin/graphics
import ../graphics/graphics as localGraphics

type
    UISprite* = object of Sprite
        renderSecs: array[0..2, array[0..2, Rectangle]]
        center: Rectangle

proc setCenter(sprite: var UISprite, center: Rectangle) =
    sprite.center = center
    for i in 0..2:
        sprite.renderSecs[0][i].X = sprite.sourceBounds.X
        sprite.renderSecs[0][i].Width = sprite.center.X - sprite.sourceBounds.X
        sprite.renderSecs[1][i].X = sprite.center.X
        sprite.renderSecs[1][i].Width = sprite.center.Width
        sprite.renderSecs[2][i].X = sprite.center.X + sprite.center.Width
        sprite.renderSecs[2][i].Width = (sprite.sourceBounds.X +
                sprite.sourceBounds.Width) - (sprite.center.X +
                sprite.center.Width)
        sprite.renderSecs[i][0].Y = sprite.sourceBounds.Y
        sprite.renderSecs[i][0].Height = center.Y - sprite.sourceBounds.Y
        sprite.renderSecs[i][1].Y = sprite.center.Y
        sprite.renderSecs[i][1].Height = sprite.center.Height
        sprite.renderSecs[i][2].Y = sprite.center.Y + sprite.center.Height
        sprite.renderSecs[i][2].Height = (sprite.sourceBounds.Y +
                sprite.sourceBounds.Height) - (sprite.center.Y +
                sprite.center.Height)

proc initUiSprite*(texture: ptr Texture, sourceBounds,
        center: Rectangle): UISprite =
    result.texture = texture
    result.sourceBounds = sourceBounds
    result.setCenter(center)

proc range(start, stop, step: int): seq[int] =
    var i = start
    while i < stop:
        result.add(i)
        i += step

proc drawSec*(sprite: var UISprite, src: Point, dest: var Rectangle) =
    var lol = sprite.renderSecs[src.X][src.Y]
    dest.Width *= SCALE
    dest.Height *= SCALE
    dest.X *= SCALE
    dest.Y *= SCALE
    sprite.texture[].draw(lol, dest)

proc draw*(sprite: var UISprite, renderRect: Rectangle) =
    if sprite.center.Width == 0 or sprite.center.Height == 0:
        return
    var tmp: Rectangle
    var rrtmp = renderRect

    # rrtmp.X = SCALE * rrtmp.X
    # rrtmp.Y = SCALE * rrtmp.Y
    # rrtmp.Width = SCALE * rrtmp.Width
    # rrtmp.Height = SCALE * rrtmp.Height
    rrtmp.Width -= (rrtmp.Width - sprite.renderSecs[0][0].Width -
            sprite.renderSecs[2][0].Width) mod sprite.center.Width
    rrtmp.Height -= (rrtmp.Height - sprite.renderSecs[0][0].Height -
            sprite.renderSecs[0][2].Height) mod sprite.center.Height

    # Draw Sections other than A C G and I
    for x in range(rrtmp.X + sprite.renderSecs[0][0].Width, (rrtmp.X +
            rrtmp.Width) - sprite.renderSecs[0][2].Width, sprite.renderSecs[1][1].Width):
        tmp = sprite.renderSecs[1][0]
        tmp.location = initPoint(x.cint, rrtmp.Y)
        sprite.drawSec(initPoint(1, 0), tmp)
        for y in range(rrtmp.Y + sprite.renderSecs[0][0].Height, (rrtmp.Y +
                rrtmp.Height) - sprite.renderSecs[2][0].Height,
                sprite.renderSecs[1][1].Height):
            tmp = sprite.renderSecs[1][1]
            tmp.location = initPoint(x.cint, y.cint)
            sprite.drawSec(initPoint(1, 1), tmp)
        tmp = sprite.renderSecs[1][2]
        tmp.location = initPoint(x.cint, (rrtmp.Y + rrtmp.Height) -
                sprite.renderSecs[0][2].Height)
        sprite.drawSec(initPoint(1, 2), tmp)
    for y in range(rrtmp.Y + sprite.renderSecs[0][0].Height, (rrtmp.Y +
            rrtmp.Height) - sprite.renderSecs[2][0].Height, sprite.renderSecs[
            1][1].Height):
        tmp = sprite.renderSecs[0][1]
        tmp.location = initPoint(rrtmp.X, y.cint)
        sprite.drawSec(initPoint(0, 1), tmp)

        tmp = sprite.renderSecs[2][1]
        tmp.location = initPoint((rrtmp.X + rrtmp.Width) - sprite.renderSecs[2][
                0].Width, y.cint)
        sprite.drawSec(initPoint(2, 1), tmp)

    tmp = sprite.renderSecs[0][0]
    tmp.location = initPoint(rrtmp.X, rrtmp.Y)
    sprite.drawSec(initPoint(0, 0), tmp)

    tmp = sprite.renderSecs[2][0]
    tmp.location = initPoint(rrtmp.X, (rrtmp.Y + rrtmp.Height) -
            sprite.renderSecs[0][2].Height)
    sprite.drawSec(initPoint(2, 0), tmp)

    tmp = sprite.renderSecs[0][2]
    tmp.location = initPoint((rrtmp.X + rrtmp.Width) - sprite.renderSecs[2][
            0].Width, rrtmp.Y)
    sprite.drawSec(initPoint(0, 2), tmp)

    tmp = sprite.renderSecs[2][2]
    tmp.location = initPoint((rrtmp.X + rrtmp.Width) - sprite.renderSecs[2][
            0].Width, (rrtmp.Y + rrtmp.Height) - sprite.renderSecs[0][2].Height)
    sprite.drawSec(initPoint(2, 2), tmp)

