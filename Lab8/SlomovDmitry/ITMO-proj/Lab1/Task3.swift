struct PriorityQueue<Element> {
    private var items: [(value: Element, priority: Int)] = []

    var isEmpty: Bool {
        items.isEmpty
    }

    var count: Int {
        items.count
    }

    mutating func enqueue(_ value: Element, priority: Int) {
        items.append((value: value, priority: priority))
    }

    func peek() -> Element? {
        guard let index = highestPriorityIndex() else {
            return nil
        }

        return items[index].value
    }

    mutating func dequeue() -> Element? {
        guard let index = highestPriorityIndex() else {
            return nil
        }

        return items.remove(at: index).value
    }

    private func highestPriorityIndex() -> Int? {
        guard !items.isEmpty else {
            return nil
        }

        var bestIndex = 0

        for index in items.indices {
            // Строгое сравнение сохраняет порядок при равных приоритетах.
            if items[index].priority > items[bestIndex].priority {
                bestIndex = index
            }
        }

        return bestIndex
    }
}

func runTask3() {
    // Большее число означает более высокий приоритет.
    var taskQueue = PriorityQueue<String>()

    taskQueue.enqueue("Read notes", priority: 1)
    taskQueue.enqueue("Fix crash", priority: 5)
    taskQueue.enqueue("Submit lab", priority: 5)
    taskQueue.enqueue("Check email", priority: 2)

    print("Count:", taskQueue.count) // 4
    print("Next:", taskQueue.peek() ?? "Queue is empty") // Fix crash
    print("Count after peek:", taskQueue.count) // 4

    while let task = taskQueue.dequeue() {
        print(task)
    }
    // Fix crash
    // Submit lab
    // Check email
    // Read notes

    print("Empty:", taskQueue.isEmpty) // true
    print("Peek returns nil:", taskQueue.peek() == nil) // true
    print("Dequeue returns nil:", taskQueue.dequeue() == nil) // true

    // Очередь можно использовать и после полного опустошения.
    taskQueue.enqueue("Review feedback", priority: -1)
    print("Reused queue:", taskQueue.dequeue() ?? "Queue is empty")
}
