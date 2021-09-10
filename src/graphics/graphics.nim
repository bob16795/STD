import gin/graphics

const SCALE* = 1

type
    RenderTag* = enum
        RT_ANY
        RT_PARTICLE
        RT_ITEM
        RT_POWER
        RT_LIQUID
        RT_FACTORS
        RT_TEMPLATE
    Sprite* = object of RootObj
        texture*: ptr Texture
        sourceBounds*: Rectangle
        tag*: RenderTag
    Animation* = object
        playing*: bool
        frames*: seq[Sprite]
        currentAFrame*: int
        framesPerAFrame: int

var aniCounter*: int

# sprite procs
proc initSprite*(texture: ptr Texture, x, y, w, h: cint,
        tag: RenderTag): Sprite =
    result.texture = texture
    result.sourceBounds = initRectangle(x, y, w, h)
    result.tag = tag

proc initSprite*(texture: ptr Texture, bounds: Rectangle,
        tag: RenderTag): Sprite =
    result.texture = texture
    result.sourceBounds = bounds
    result.tag = tag

proc draw*(sprite: var Sprite, position: Point, visible: seq[RenderTag],
        rotation: uint) =
    if ((visible.len != 0 and sprite.tag == RT_ANY) or visible.contains(sprite.tag)):
        sprite.texture[].draw(sprite.sourceBounds, initRectangle(position *
                SCALE, sprite.sourceBounds.size * SCALE), rotation.float32)

proc draw*(sprite: var Sprite, position: Point, visible: seq[RenderTag],
        rotation: uint, size: Point) =
    if ((visible.len != 0 and sprite.tag == RT_ANY) or visible.contains(sprite.tag)):
        sprite.texture[].draw(sprite.sourceBounds, initRectangle(position *
                SCALE, size * SCALE), rotation.float32)

proc draw*(sprite: var Sprite, position: Point, visible: seq[RenderTag],
        rotation: uint, size: Point, c: Color) =
    if ((visible.len != 0 and sprite.tag == RT_ANY) or visible.contains(sprite.tag)):
        sprite.texture[].draw(sprite.sourceBounds, initRectangle(position *
                SCALE, size * SCALE), c, rotation.float32)

# animation procs
proc initAnimation*(frames: seq[Sprite], framesPerAFrame: int): Animation =
    result.frames = frames
    result.framesPerAFrame = framesPerAFrame
    result.currentAFrame = 0
    result.playing = true

proc draw*(animation: var Animation, position: Point, rotation: uint,
        visible: seq[RenderTag]) =
    if animation.currentAFrame > len(animation.frames) - 1 or
            animation.currentAFrame < 0:
        animation.currentAframe = 0
    if animation.frames.len == 0:
        return
    animation.frames[animation.currentAFrame].draw(position, visible, rotation)

proc draw*(animation: var Animation, position: Point, rotation: uint,
        visible: seq[RenderTag], size: Point) =
    if animation.currentAFrame > len(animation.frames) - 1 or
            animation.currentAFrame < 0:
        animation.currentAframe = 0
    if animation.frames.len == 0:
        return
    animation.frames[animation.currentAFrame].draw(position, visible, rotation, size)

proc update*(animation: var Animation, time: cuint) =
    if not animation.playing or animation.framesPerAFrame == 0:
        return
    animation.currentAFrame = (aniCounter /
            animation.framesPerAFrame).int mod animation.frames.len
