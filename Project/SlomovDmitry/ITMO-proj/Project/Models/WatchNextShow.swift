import Foundation

// Общая модель приложения. Сетевой ответ преобразуется в неё отдельно.
// Описание одного фильма внутри приложения
nonisolated struct WatchNextShow: Identifiable, Sendable {
    let id: Int
    let name: String
    let url: String
    let genres: [String]
    let summary: String?
    let premiered: String?
    let rating: Rating?
    let image: Image?
    var source: String = "tvmaze"
    var kind: String? = nil

    // В двух каталогах могут встретиться одинаковые числовые id.
    var catalogID: String { "\(source):\(id)" }

    var kindTitle: String {
        switch kind {
        case "movie": return "Фильм"
        case "tv-series": return "Сериал"
        case "cartoon": return "Мультфильм"
        case "animated-series": return "Мультсериал"
        case "anime": return "Аниме"
        case "tv-show": return "Телешоу"
        default: return source == "tvmaze" ? "Сериал" : "Кино"
        }
    }

    nonisolated struct Rating: Sendable {
        let average: Double?
    }

    nonisolated struct Image: Sendable {
        let medium: String?
        let original: String?
    }

    var imageURL: URL? {
        guard let address = image?.medium ?? image?.original else { return nil }
        return URL(string: address)
    }

    var ratingText: String {
        guard let average = rating?.average else { return "Нет оценки" }
        return String(format: "%.1f", average)
    }

    var year: String {
        guard let premiered = premiered, premiered.count >= 4 else {
            return "Год не указан"
        }
        return String(premiered.prefix(4))
    }

    var overview: String {
        guard var text = summary else { return "Описание пока отсутствует." }

        // У старых записей TVmaze описание может содержать HTML-разметку.
        text = text.replacingOccurrences(
            of: "(?i)<br\\s*/?>|</p\\s*>",
            with: "\n",
            options: .regularExpression
        )
        text = text.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )

        let entities = [
            ("&nbsp;", " "), ("&quot;", "\""),
            ("&apos;", "'"), ("&#39;", "'"), ("&#x27;", "'"),
            ("&lsquo;", "‘"), ("&rsquo;", "’"),
            ("&ldquo;", "“"), ("&rdquo;", "”"),
            ("&ndash;", "–"), ("&mdash;", "—"), ("&hellip;", "…"),
            ("&lt;", "<"), ("&gt;", ">"), ("&amp;", "&")
        ]
        for (entity, character) in entities {
            text = text.replacingOccurrences(of: entity, with: character)
        }

        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? "Описание пока отсутствует." : text
    }
}
