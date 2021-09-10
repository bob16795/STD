template ifor*(variable: untyped, list: untyped, body: untyped): untyped =
    for i in 0..<list.len:
        template variable(): untyped = list[i]
        body