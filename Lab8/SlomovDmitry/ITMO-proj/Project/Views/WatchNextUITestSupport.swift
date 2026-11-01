import Foundation

// Режим включается только UI-тестами в Debug-сборке.
// База и настройки изолированы, каталог не требует сети или ключа API.
@MainActor
enum WatchNextUITestSupport {
    static var isEnabled: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains("--watchnext-ui-testing")
        #else
        false
        #endif
    }

    static let defaults: UserDefaults = {
        #if DEBUG
        if isEnabled {
            let suiteName = "WatchNext.UITests"
            guard let defaults = UserDefaults(suiteName: suiteName) else {
                fatalError("Не удалось создать настройки для UI-тестов")
            }
            defaults.removePersistentDomain(forName: suiteName)
            return defaults
        }
        #endif
        return .standard
    }()

    static var catalogShows: [WatchNextShow]? {
        #if DEBUG
        guard isEnabled else { return nil }
        return [
            WatchNextShow(
                id: 1,
                name: "Интерстеллар",
                url: "https://example.com/interstellar",
                genres: ["Фантастика", "Драма"],
                summary: "Путешествие за пределы Солнечной системы.",
                premiered: "2014",
                rating: .init(average: 8.6),
                image: nil,
                source: "uitest",
                kind: "movie"
            ),
            WatchNextShow(
                id: 2,
                name: "Дюна",
                url: "https://example.com/dune",
                genres: ["Фантастика"],
                summary: "История далёкой пустынной планеты.",
                premiered: "2021",
                rating: .init(average: 8.0),
                image: nil,
                source: "uitest",
                kind: "movie"
            )
        ]
        #else
        return nil
        #endif
    }
}
