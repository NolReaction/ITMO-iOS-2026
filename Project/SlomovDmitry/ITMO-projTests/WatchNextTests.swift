import Foundation
import SwiftData
import XCTest
@testable import ITMO_proj

final class WatchNextTests: XCTestCase {
    // Ответ сервера: пропускаем неверные id и используем запасные поля вместо пустых строк.
    func testMovieResponseSkipsInvalidRecordsAndUsesFallbackFields() throws {
        // Подготовка: только одна из трёх записей содержит корректный id.
        let json = """
        {
          "docs": [
            {
              "id": 101,
              "name": "   ",
              "alternativeName": " Arrival ",
              "description": " ",
              "shortDescription": " First contact ",
              "year": 2016,
              "type": "movie",
              "rating": { "kp": 8.0 },
              "genres": [{ "name": " фантастика " }, { "name": " " }]
            },
            { "id": 0, "name": "Invalid movie" },
            { "name": "Missing id" }
          ]
        }
        """

        // Действие: разбираем настоящий формат API и преобразуем его в модель приложения.
        let response = try JSONDecoder().decode(WatchNextMovieResponse.self, from: Data(json.utf8))
        let shows = response.shows

        // Проверка: неверные записи убраны, пробелы очищены, запасные поля подставлены.
        XCTAssertEqual(shows.count, 1)
        let show = try XCTUnwrap(shows.first)
        XCTAssertEqual(show.name, "Arrival")
        XCTAssertEqual(show.summary, "First contact")
        XCTAssertEqual(show.genres, ["фантастика"])
        XCTAssertEqual(show.premiered, "2016")
        XCTAssertEqual(show.rating?.average, 8.0)
        XCTAssertEqual(show.catalogID, "poiskkino:101")
    }

    // Выбор «На вечер»: выбранный жанр соблюдается, прошлый фильм не повторяется при наличии другого.
    func testGenreFilterAndSelectionExcludePreviousMovie() {
        // Подготовка: два фильма с драмой и одна комедия.
        let previous = makeShow(id: 1, name: "Arrival", genres: ["драма", "фантастика"])
        let alternative = makeShow(id: 2, name: "Interstellar", genres: ["драма", "фантастика"])
        let comedy = makeShow(id: 3, name: "The Mask", genres: ["комедия"])
        let shows = [previous, alternative, comedy]

        // Действие: фильтруем по драме, затем выбираем фильм, исключив предыдущий.
        let filtered = WatchNextRules.filter(shows, genre: "драма")
        let selected = WatchNextRules.pick(from: filtered, excluding: previous.catalogID)

        // Проверка: после исключения остаётся один вариант, поэтому случайности в тесте нет.
        XCTAssertEqual(WatchNextRules.genres(in: shows), ["драма", "комедия", "фантастика"])
        XCTAssertEqual(filtered.map(\.catalogID), [previous.catalogID, alternative.catalogID])
        XCTAssertEqual(selected?.catalogID, alternative.catalogID)
        XCTAssertNil(WatchNextRules.pick(from: [], excluding: nil))
    }

    // async обходит сбой XCTest при освобождении MainActor-объектов в Swift 6.2.
    @MainActor
    func testAddingSameMovieTwiceStoresOnlyOneEntry() async throws {
        // Подготовка: отдельная база в памяти, без доступа к пользовательскому списку.
        let container = try makeContainer()
        let library = WatchNextLibraryViewModel(context: container.mainContext)
        let show = makeShow(id: 101, name: "Arrival", genres: ["фантастика"])

        // Действие: пользователь дважды добавляет один и тот же фильм.
        XCTAssertTrue(library.add(show))
        XCTAssertTrue(library.add(show))

        // Проверка: новая ViewModel читает из базы ровно одну запись с исходным статусом.
        let reloaded = WatchNextLibraryViewModel(context: ModelContext(container))
        XCTAssertEqual(reloaded.entries.count, 1)
        let saved = try XCTUnwrap(reloaded.entry(for: show))
        XCTAssertEqual(saved.catalogID, show.catalogID)
        XCTAssertEqual(saved.status, .planned)
        XCTAssertNil(library.errorMessage)
    }

    @MainActor
    func testStatusChangeAndRemovalArePersisted() async throws {
        // Подготовка: добавляем фильм в изолированную базу.
        let container = try makeContainer()
        let library = WatchNextLibraryViewModel(context: container.mainContext)
        let show = makeShow(id: 102, name: "Interstellar", genres: ["фантастика"])
        XCTAssertTrue(library.add(show))
        let saved = try XCTUnwrap(library.entry(for: show))

        // Действие: меняем статус, затем читаем сохранённое значение через новый контекст.
        XCTAssertTrue(library.updateStatus(.finished, for: saved))
        let reloaded = WatchNextLibraryViewModel(context: ModelContext(container))
        let finished = try XCTUnwrap(reloaded.entry(for: show))

        // Проверка: статус сохранился; удаление тоже записывается в базу.
        XCTAssertEqual(finished.status, .finished)
        XCTAssertTrue(reloaded.remove(finished))
        let afterRemoval = WatchNextLibraryViewModel(context: ModelContext(container))
        XCTAssertTrue(afterRemoval.entries.isEmpty)
        XCTAssertNil(reloaded.errorMessage)
    }

    @MainActor
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([WatchNextSavedShow.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private func makeShow(id: Int, name: String, genres: [String]) -> WatchNextShow {
        WatchNextShow(
            id: id,
            name: name,
            url: "https://www.kinopoisk.ru/film/\(id)/",
            genres: genres,
            summary: nil,
            premiered: nil,
            rating: nil,
            image: nil,
            source: "poiskkino",
            kind: "movie"
        )
    }
}
