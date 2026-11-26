Assert := {}.{
    equal = |expected, actual|
        if actual == expected
            True
        else {
            dbg { expected, actual }
            False
        }
}
