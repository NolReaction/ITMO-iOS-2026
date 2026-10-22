//
//  ITMO_projTests.swift
//  ITMO-projTests
//
//  Created by Дмитрий Сломов on 10.09.2026.
//

import Testing
import XCTest
// Подключает встроенный инструмент Apple для тестирования
@testable import ITMO_proj

final class ITMO_projTests: XCTestCase {

    // Сценарий 1: обработка публикации с лишними пробелами и переносами.
    // Ожидаем обычные пробелы между словами и правильное количество слов.
    func testMakeItemNormalizesTextAndCountsWords() {
        // Подготовка: в заголовке и тексте по два слова.
        let post = Lab6Post(
            userId: 1,
            id: 1,
            title: "  Hello   Swift \n",
            body: "\tFirst  post\n"
        )

        // Действие: вызываем настоящую функцию обработки публикации.
        let item = Lab6PostProcessor.makeItem(from: post)

        // Проверка: лишние пробелы убраны, всего получилось четыре слова.
        // XCTAssertEqual сравнивает фактическое значение с ожидаемым.
        XCTAssertEqual(item.title, "Hello Swift")
        XCTAssertEqual(item.body, "First post")
        XCTAssertEqual(item.wordCount, 4)
    }

    // Сценарий 2: публикации пришли в неправильном порядке.
    // Ожидаем сортировку по id и сумму слов во всех публикациях.
    func testMakeFeedSortsPostsAndCountsTotalWords() {
        // Подготовка: запись №2 содержит два слова, запись №1 - три.
        let posts = [
            Lab6Post(userId: 1, id: 2, title: "Second", body: "three"),
            Lab6Post(userId: 1, id: 1, title: "First", body: "one two")
        ]

        // Действие: формируем ленту из двух публикаций.
        let feed = Lab6PostProcessor.makeFeed(from: posts)

        // Проверка: сначала запись №1, затем №2; всего 3 + 2 = 5 слов.
        // map(\.id) берёт только id каждой записи для сравнения порядка.
        XCTAssertEqual(feed.posts.map(\.id), [1, 2])
        XCTAssertEqual(feed.totalWordCount, 5)
    }
}
