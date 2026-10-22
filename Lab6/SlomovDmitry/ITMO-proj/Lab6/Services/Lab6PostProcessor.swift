import Foundation

// Чистые преобразования: их удобно объяснять и тестировать отдельно от сети.
// В общем проекте по умолчанию MainActor. Эти функции доступны фоновой очереди.
nonisolated enum Lab6PostProcessor {
    static func makeItem(from post: Lab6Post) -> Lab6PostItem {
        let title = normalized(post.title)
        let body = normalized(post.body)
        let wordCount = (title + " " + body).split(whereSeparator: { $0.isWhitespace }).count

        return Lab6PostItem(
            id: post.id,
            userId: post.userId,
            title: title,
            body: body,
            wordCount: wordCount
        )
    }

    static func makeFeed(from posts: [Lab6Post]) -> Lab6PostFeed {
        let items = posts.sorted { $0.id < $1.id }.map { makeItem(from: $0) }
        return Lab6PostFeed(
            posts: items,
            totalWordCount: items.reduce(0) { $0 + $1.wordCount }
        )
    }

    private static func normalized(_ text: String) -> String {
        text.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }
}
