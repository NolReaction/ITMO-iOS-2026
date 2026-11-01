# Лабораторная работа №8: SwiftLint

Дмитрий Сломов, группа 4140.

SwiftLint подключён к приложению через Homebrew и Run Script в Xcode.
При сборке автоматически проверяются исходники Lab6, WatchNext и учебная папка SwiftLintDemo.

## Запуск

1. Установить SwiftLint: `brew install swiftlint`.
2. Открыть `Lab8/SlomovDmitry/ITMO-proj.xcodeproj` в Xcode 26.2+.
3. Выбрать схему ITMO-proj и iPhone Simulator с iOS 26.2+.
4. Нажать ⌘B. Замечания SwiftLint отображаются в Issue Navigator (⌘5).

Из папки рядом с .xcodeproj проверку можно запустить вручную:

```bash
swiftlint lint --strict --config .swiftlint.yml
```

## Правила

- `line_length`: предупреждение после 120 символов, ошибка после 200.
- `identifier_name`: минимальная длина имени, исключения для id, x, y.
- `force_unwrapping`: предупреждение о принудительном извлечении optional через !.
- `trailing_whitespace`: пробелы в конце строк.

Используются стандартные правила со своей конфигурацией.
Замечания исправлены в коде; правила не отключены ради прохождения проверки.

## Область проверки и исключения

`included`: ITMO-proj/Lab6, ITMO-proj/Project, SwiftLintDemo.

`excluded`: SwiftLintDemo/Excluded, SwiftLintDemo/IgnoredFile.swift,
ITMO-projTests и ITMO-projUITests.

Run Script добавляет Homebrew в PATH, переходит в $SRCROOT и читает .swiftlint.yml.
Для app target User Script Sandboxing установлен в No.
Based on dependency analysis у скрипта выключен.

## Демонстрация

В `SwiftLintDemo/Example.swift` находится исправленный пример.
Инструкция временного добавления нарушений, их исправления и демонстрации
исключений находится в `SwiftLintDemo/README.md`.
Учебные файлы не включены в target приложения.

В приложение включены лабораторные 1–6 и WatchNext для демонстрации проверки
на настоящих исходниках. WatchNext использует URLSession; Alamofire применяется в Lab6.
Обычный каталог WatchNext требует ключ ПоискКино в настройках приложения.
Автоматические тесты используют локальные данные и отдельную базу в памяти.

## Проверка

Swift-исходники, Xcode-проект, конфигурация и тесты совпадают с проверенным финальным
проектом; изменено только внешнее расположение папки и описание сдачи.

Xcode 26.2 (17C52), iPhone 17 Pro, iOS 26.2:
SwiftLint 0.65.1 --strict — 0 нарушений в 25 файлах.
Все 10 тестов прошли: 6 unit и 4 UI, включая 4 unit и 2 UI для WatchNext.

Результат: https://github.com/NolReaction/ITMO-iOS-2026/actions/runs/41315722141
