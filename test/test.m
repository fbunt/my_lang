fn add10(a: int) -> int {
    for i in (0 .. 10) {
        a = a + 1
    }
    return a
}

fn sub5(a: double) -> double {
    i: int = 5
    while i > 0 {
        a = a - 1
        i = i - 1
    }
    return a
}

fn main() {
    printi(add10(2))
    printd(sub5(10))
}
