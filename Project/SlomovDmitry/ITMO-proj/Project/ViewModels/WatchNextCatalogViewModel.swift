import Combine
import Foundation

// Управление каталогом и поиском
@MainActor
final class WatchNextCatalogViewModel: ObservableObject {
    @Published private(set) var shows: [WatchNextShow] = [] // найденные фильмы
    @Published private(set) var isLoading = false // показывать ли индикатор загрузки
    @Published private(set) var errorMessage: String? // текст ошибки
    @Published private(set) var loadedQuery = "" // по какому запросу получены результаты

    private let api = WatchNextAPI() // объект сетевого сервиса WatchNextAPI
    private var hasLoaded = false // была ли уже успешная загрузка

    /*
     Проверяет hasLoaded. Если ещё ничего не загружали, вызывает load(query:)
     */
    func loadIfNeeded(query: String = "") async {
        if !hasLoaded { await load(query: query) }
    }

    /* Проверяем, не идёт ли уже загрузка.
     Включаем isLoading, очищаем старую ошибку и результаты.
     Если запрос пустой - вызываем api.discover(). Если есть название - api.search(query).
     Полученные фильмы записываем в shows.
     При ошибке записываем сообщение в errorMessage.
     Через defer выключаем isLoading.
     */
    func load(query: String) async {
        guard !isLoading else { return }
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        isLoading = true
        errorMessage = nil
        shows = []
        loadedQuery = query
        defer { isLoading = false }

        do {
            let result: [WatchNextShow]
            if query.isEmpty {
                result = try await api.discover()
            } else {
                result = try await api.search(query)
            }
            try Task.checkCancellation()
            shows = result
            loadedQuery = query
            hasLoaded = true
        } catch is CancellationError {
            // Уход с экрана может отменить загрузку. Это не ошибка для пользователя.
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
