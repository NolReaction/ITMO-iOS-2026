import Foundation

// Чистые функции: не зависят от интерфейса, сети и базы данных.
// Три функции выбора
nonisolated enum WatchNextRules {
    static func genres(in shows: [WatchNextShow]) -> [String] {
        Array(Set(shows.flatMap { $0.genres })).sorted()
    }

    static func filter(_ shows: [WatchNextShow], genre: String) -> [WatchNextShow] {
        guard genre != "Все жанры" else { return shows }
        return shows.filter { $0.genres.contains(genre) }
    }

    static func pick(from shows: [WatchNextShow], excluding previousID: String?) -> WatchNextShow? {
        let otherShows = shows.filter { $0.catalogID != previousID }
        // Единственный вариант можно предложить повторно. Пустой список даёт nil.
        return otherShows.isEmpty ? shows.randomElement() : otherShows.randomElement()
    }
}
