import enemy
import gin/graphics
import gin/events

type
    EnemyKind* = enum
        Normal,
        Fast,
        Invis,
        Strong,
        StrongInvis,
        Buff,
        BuffInvis
    Round* = object
        running*: bool
        enemies*: seq[tuple[kind: EnemyKind, time: int]]
        path*: seq[Point]
        start*: Point

proc update*(r: var Round, dt: cuint, eb: var EventBus): Enemy =
    if r.enemies == @[]:
        return
    r.enemies[0].time -= dt.int
    if r.enemies[0].time <= 0:
        if r.enemies.len != 1:
            r.enemies = r.enemies[1..^1]
        else:
            return
        case r.enemies[0].kind:
        of Invis:
            return Enemy(valid: true, invis: true, pos: r.start,
                    pathLeft: r.path, speed: 1, hp: 2)
        of Normal:
            return Enemy(valid: true, pos: r.start, pathLeft: r.path, speed: 1, hp: 2)
        of Fast:
            return Enemy(valid: true, pos: r.start, pathLeft: r.path,
                    speed: 1.5, hp: 2)
        of Strong:
            return Enemy(skin: 1, valid: true, pos: r.start,
                    pathLeft: r.path, speed: 1, hp: 6)
        of StrongInvis:
            return Enemy(skin: 1, valid: true, invis: true, pos: r.start,
                    pathLeft: r.path, speed: 1, hp: 6)
        of Buff:
            return Enemy(skin: 1, valid: true, pos: r.start,
                    pathLeft: r.path, speed: 1, hp: 15)
        of BuffInvis:
            return Enemy(skin: 1, valid: true, invis: true, pos: r.start,
                    pathLeft: r.path, speed: 1, hp: 15)
    return
