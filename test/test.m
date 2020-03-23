// Add 10 to a
fn add10(a: int) -> int {
    // I wasn't able to get rid of the pesky spaces in the range
    for i in (0 .. 10) {
        a = a + 1
    }
    return a
}

/*
This is a block comment
*/
fn sub5(a: double) -> double {
    i: int = 5
    while i > 0 {
        a = a - 1
        i = i - 1
    }
    return a
}

fn add25(a: int) -> int {
    for i in (0 .. 5 * 5) {
        a = a + /* Don't mind me */ 1
    }
    return a
}

fn main() {
    /*
     * There are two builtin print functions currently:
     * fn printi(arg: int)
     * fn printd(arg: double)
     */
    printi(add10(2))
    printd(sub5(10))
    printi(add25(5))
}
