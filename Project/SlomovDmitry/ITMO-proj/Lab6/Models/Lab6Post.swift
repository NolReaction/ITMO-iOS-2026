import Foundation

// JSON сервера: имена свойств совпадают с ключами ответа.
nonisolated struct Lab6Post: Codable, Identifiable, Sendable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

// У новой записи ещё нет id. Его возвращает сервер в ответе на POST.
nonisolated struct Lab6NewPost: Encodable, Sendable {
    let userId: Int
    let title: String
    let body: String
}

// Данные, подготовленные для экрана после разбора JSON.
nonisolated struct Lab6PostItem: Identifiable, Sendable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
    let wordCount: Int
}

nonisolated struct Lab6PostFeed: Sendable {
    let posts: [Lab6PostItem]
    let totalWordCount: Int
}
