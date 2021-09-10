import gin/graphics

type
    HitboxKind* = enum
        hkCircle
        hkRectangle
    HitBox* = object
        kind: HitboxKind
        bounds*: Rectangle

proc initHitBox*(bounds: Rectangle, kind: HitboxKind): HitBox =
    result.bounds = bounds
    result.kind = kind

proc AABB(a, b: Rectangle): bool =
    return a.X < b.X + b.Width and a.X + a.Width > b.X and a.Y < b.Y +
            b.Height and a.Y + a.Height > b.Y

proc CIRCLE(a, b: Rectangle): bool =
    return a.Width / 2 + b.Width / 2 < distance(a.center, b.center)

proc AABBCIRCLE(a, b: Rectangle): bool =
    var pt = b.center

    if (pt.X > a.X): pt.X = a.X
    if (pt.X < a.X + a.Width): pt.X = a.X + a.Width
    if (pt.Y > a.Y): pt.Y = a.Y
    if (pt.X < a.Y + a.Height): pt.X = a.Y + a.Height

    return distance(pt, b.center) < b.Width / 2

proc checkCollision*(a, b: HitBox): bool =
    if (a.kind == hkRectangle):
        if (b.kind == hkRectangle): return AABB(a.bounds, b.bounds)
        if (b.kind == hkCircle): return AABBCIRCLE(a.bounds, b.bounds)
    if (a.kind == hkCircle):
        if (b.kind == hkRectangle): return AABBCIRCLE(b.bounds, a.bounds)
        if (b.kind == hkCircle): return CIRCLE(a.bounds, b.bounds)
