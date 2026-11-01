import Foundation
import SwiftData

// запись фильма для базы данных
enum WatchNextStatus: String, CaseIterable, Identifiable {
    case planned
    case watching
    case finished

    var id: String { rawValue }

    var title: String {
        switch self {
        case .planned: return "Хочу посмотреть"
        case .watching: return "Смотрю"
        case .finished: return "Просмотрено"
        }
    }
}

// Cохраняемая запись фильма
@Model
final class WatchNextSavedShow {
    // Уникальность проверяет ViewModel по паре source + showID.
    var showID: Int
    var source: String = "tvmaze"
    var kind: String? = nil
    var name: String
    var sourceURL: String
    var imageURL: String?
    var summary: String?
    var genres: [String]
    var premiered: String?
    var rating: Double?
    var statusRaw: String
    var addedAt: Date

    init(show: WatchNextShow) {
        showID = show.id
        source = show.source
        kind = show.kind
        name = show.name
        sourceURL = show.url
        imageURL = show.image?.medium ?? show.image?.original
        summary = show.summary
        genres = show.genres
        premiered = show.premiered
        rating = show.rating?.average
        statusRaw = WatchNextStatus.planned.rawValue
        addedAt = Date()
    }

    var catalogID: String { "\(source):\(showID)" }

    var status: WatchNextStatus {
        get { WatchNextStatus(rawValue: statusRaw) ?? .planned }
        set { statusRaw = newValue.rawValue }
    }

    var show: WatchNextShow {
        WatchNextShow(
            id: showID,
            name: name,
            url: sourceURL,
            genres: genres,
            summary: summary,
            premiered: premiered,
            rating: rating.map { .init(average: $0) },
            image: imageURL.map { .init(medium: $0, original: $0) },
            source: source,
            kind: kind
        )
    }
}
