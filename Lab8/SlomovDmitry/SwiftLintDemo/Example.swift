func lintExample() -> String {
    let answer = 42
    let optionalTitle: String? = "Demo"
    let title = optionalTitle ?? "Untitled"
    return "\(title): \(answer)"
}
