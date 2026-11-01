import XCTest

final class WatchNextUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // Каталог → карточка → добавление → фильм появился в личном списке.
    @MainActor
    func testAddMovieFromCatalogToLibrary() {
        let app = launchWatchNext()
        addMovie(in: app)

        app.navigationBars["Подробности"].buttons.element(boundBy: 0).tap()
        app.tabBars.buttons["Мой список"].tap()

        let movie = app.buttons["watchnext.library.uitest:1"]
        XCTAssertTrue(movie.waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["watchnext.library.count"].label, "Сохранено: 1")
        XCTAssertEqual(
            app.staticTexts["watchnext.library.status.uitest:1"].label,
            "Хочу посмотреть"
        )
    }

    // Меняем статус и проверяем, что фильтр скрывает только просмотренный фильм.
    @MainActor
    func testFinishedMovieCanBeHiddenAndShownAgain() {
        let app = launchWatchNext()
        addMovie(in: app)

        let statusPicker = app.buttons["watchnext.status"]
        scrollTo(statusPicker, in: app)
        statusPicker.tap()
        let finished = app.buttons["Просмотрено"]
        XCTAssertTrue(finished.waitForExistence(timeout: 5))
        finished.tap()

        // Второй фильм оставляем в статусе «Хочу посмотреть».
        app.navigationBars["Подробности"].buttons.element(boundBy: 0).tap()
        addMovie("uitest:2", in: app)
        app.navigationBars["Подробности"].buttons.element(boundBy: 0).tap()
        app.tabBars.buttons["Мой список"].tap()

        let movie = app.buttons["watchnext.library.uitest:1"]
        let plannedMovie = app.buttons["watchnext.library.uitest:2"]
        XCTAssertTrue(movie.waitForExistence(timeout: 5))
        XCTAssertTrue(plannedMovie.exists)
        XCTAssertEqual(app.staticTexts["watchnext.library.status.uitest:1"].label, "Просмотрено")

        let hideFinished = app.switches["watchnext.hideFinished"]
        hideFinished.tap()
        let hidden = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: movie)
        XCTAssertEqual(XCTWaiter.wait(for: [hidden], timeout: 5), .completed)
        XCTAssertTrue(plannedMovie.exists)
        XCTAssertEqual(app.staticTexts["watchnext.library.count"].label, "Сохранено: 2")

        hideFinished.tap()
        XCTAssertTrue(movie.waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["watchnext.library.status.uitest:1"].label, "Просмотрено")
    }

    @MainActor
    private func launchWatchNext() -> XCUIApplication {
        let app = XCUIApplication()
        // Каждый запуск: локальный каталог, новая база в памяти, отдельные настройки.
        app.launchArguments.append("--watchnext-ui-testing")
        app.launch()

        let project = app.buttons["WatchNext: Фильмы и сериалы"]
        XCTAssertTrue(project.waitForExistence(timeout: 5))
        scrollTo(project, in: app)
        project.tap()

        XCTAssertTrue(app.buttons["watchnext.catalog.uitest:1"].waitForExistence(timeout: 5))
        return app
    }

    @MainActor
    private func addMovie(_ catalogID: String = "uitest:1", in app: XCUIApplication) {
        let movie = app.buttons["watchnext.catalog.\(catalogID)"]
        scrollTo(movie, in: app)
        movie.tap()

        let addButton = app.buttons["watchnext.add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        scrollTo(addButton, in: app)
        addButton.tap()

        XCTAssertTrue(app.buttons["watchnext.status"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func scrollTo(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<6 {
            if element.isHittable { return }
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }
}
