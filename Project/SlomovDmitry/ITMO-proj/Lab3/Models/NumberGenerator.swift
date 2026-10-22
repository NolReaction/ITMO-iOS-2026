struct NumberGenerator {
    let range = 1...100

    func generate() -> Int {
        Int.random(in: range)
    }
}
