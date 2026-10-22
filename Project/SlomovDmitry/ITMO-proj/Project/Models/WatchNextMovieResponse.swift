import Foundation

// Формат ответа провайдера отделён от модели, которую используют экраны.
// Описание данных, пришедших от сервера
nonisolated struct WatchNextMovieResponse: Decodable, Sendable {
    let docs: [Movie]

    var shows: [WatchNextShow] {
        docs.compactMap { $0.show }
    }

    nonisolated struct Movie: Decodable, Sendable {
        let id: Int?
        let name: String?
        let alternativeName: String?
        let enName: String?
        let description: String?
        let shortDescription: String?
        let year: Int?
        let type: String?
        let isSeries: Bool?
        let rating: Rating?
        let poster: Poster?
        let genres: [Genre]?

        var show: WatchNextShow? {
            guard let id = id, id > 0 else { return nil }

            let kind = Self.firstText(type)
            let series = isSeries ?? ["tv-series", "animated-series", "tv-show"].contains(kind ?? "")
            let path = series ? "series" : "film"
            let imageURL = Self.firstText(poster?.url, poster?.previewUrl)
            let previewURL = Self.firstText(poster?.previewUrl, poster?.url)

            return WatchNextShow(
                id: id,
                name: Self.firstText(name, alternativeName, enName) ?? "Без названия",
                url: "https://www.kinopoisk.ru/\(path)/\(id)/",
                genres: (genres ?? []).compactMap { Self.firstText($0.name) },
                summary: Self.firstText(description, shortDescription),
                premiered: year.flatMap { $0 > 0 ? String($0) : nil },
                rating: rating?.kp.flatMap { $0 > 0 ? WatchNextShow.Rating(average: $0) : nil },
                image: imageURL == nil ? nil : WatchNextShow.Image(
                    medium: previewURL,
                    original: imageURL
                ),
                source: "poiskkino",
                kind: kind ?? isSeries.map { $0 ? "tv-series" : "movie" }
            )
        }

        // API иногда отдаёт пустую строку вместо null.
        private static func firstText(_ values: String?...) -> String? {
            for value in values {
                if let text = value?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !text.isEmpty {
                    return text
                }
            }
            return nil
        }
    }

    nonisolated struct Rating: Decodable, Sendable {
        let kp: Double?
    }

    nonisolated struct Poster: Decodable, Sendable {
        let url: String?
        let previewUrl: String?
    }

    nonisolated struct Genre: Decodable, Sendable {
        let name: String?
    }
}
