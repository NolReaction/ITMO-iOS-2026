//
//  ITMO_projUITests.swift
//  ITMO-projUITests
//
//  Created by Дмитрий Сломов on 10.09.2026.
//

import XCTest

final class ITMO_projUITests: XCTestCase {

    override func setUpWithError() throws {
        // При неудачной проверке останавливаем текущий тест.
        continueAfterFailure = false
    }

    // Сценарий 3: пользователь открывает шестую лабораторную из меню.
    // Ожидаем экран Lab 6 с кнопкой загрузки публикаций.
    @MainActor
    func testOpenLab6Screen() {
        let app = XCUIApplication()
        app.launch()

        let lab6 = app.buttons["Lab 6: Сеть"]
        // Ждём появления элемента, чтобы успела закончиться загрузка экрана.
        XCTAssertTrue(lab6.waitForExistence(timeout: 2))
        lab6.tap()

        // loadPosts — идентификатор, уже заданный кнопке в приложении.
        // -Появилась кнопка с идентификатором loadPosts (загрузить публикации)
        XCTAssertTrue(app.buttons["loadPosts"].waitForExistence(timeout: 2))
        // -Есть верхняя панель с заголовком «Lab 6: Сеть»
        XCTAssertTrue(app.navigationBars["Lab 6: Сеть"].exists)
    }

    // Сценарий 4: пользователь нажимает на счётчик один раз.
    // Ожидаем изменение надписи с «Нажатий: 0» на «Нажатий: 1».
    @MainActor
    func testCounterIncrementsAfterTap() {
        let app = XCUIApplication()
        app.launch()

        let lab6 = app.buttons["Lab 6: Сеть"]
        XCTAssertTrue(lab6.waitForExistence(timeout: 2))
        lab6.tap()
        XCTAssertTrue(app.buttons["loadPosts"].waitForExistence(timeout: 2))

        // При новом запуске счётчик начинается с нуля.
        let counter = app.buttons["Нажатий: 0"]

        // Кнопка находится внизу списка. Прокручиваем до неё.
        // Ограничение в 6 свайпов не даёт тесту прокручиваться бесконечно.
        for _ in 0..<6 {
            if counter.isHittable { break }
            app.swipeUp()
        }

        // isHittable проверяет, что на кнопку можно нажать.
        XCTAssertTrue(counter.isHittable)
        counter.tap()

        XCTAssertTrue(app.buttons["Нажатий: 1"].waitForExistence(timeout: 2))
    }
}
