import Foundation

// Отправка запросов и обработка ответов

actor WatchNextAPI {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // Подготавливает параметры поиска по названию и вызывает fetch(...)
    func search(_ query: String) async throws -> [WatchNextShow] {
        try Task.checkCancellation()
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }

        let response: WatchNextMovieResponse = try await fetch(
            path: "/v1.5/movie/search",
            queryItems: [
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "limit", value: "30"),
                URLQueryItem(name: "query", value: query)
            ]
        )
        return response.shows
    }

    // Подготавливает параметры стартового каталога и вызывает fetch(...)
    func discover() async throws -> [WatchNextShow] {
        // Каталог по количеству оценок. Следующие порции API выдаёт по курсору.
        let fields = ["id", "name", "alternativeName", "enName", "description",
                      "shortDescription", "year", "type", "isSeries", "rating", "poster", "genres"]
        let response: WatchNextMovieResponse = try await fetch(
            path: "/v1.5/movie",
            queryItems: [
                URLQueryItem(name: "limit", value: "30"),
                URLQueryItem(name: "notNullFields", value: "name"),
                URLQueryItem(name: "sortField", value: "votes.kp"),
                URLQueryItem(name: "sortType", value: "-1")
            ] + fields.map { URLQueryItem(name: "selectFields", value: $0) }
        )
        return response.shows
    }

    // Выполняет сам запрос и читает ответ
    /* 1. Чтение ключа через WatchNextCredentials.read().
     2. Сборку адреса через URLComponents.
     3. Создание URLRequest и добавление ключа в заголовок.
     4. Отправку через session.data(for: request).
     5. Проверку HTTP-статуса.
     6. Превращение JSON в WatchNextMovieResponse через JSONDecoder.
     В конце файла находится WatchNextAPIError: перечень возможных ошибок и русские сообщения для них.
     */
    private func fetch<Value: Decodable & Sendable>(
        path: String,
        queryItems: [URLQueryItem]
    ) async throws -> Value {
        try Task.checkCancellation()
        guard let apiKey = try WatchNextCredentials.read()?
            .trimmingCharacters(in: .whitespacesAndNewlines), !apiKey.isEmpty else {
            throw WatchNextAPIError.missingKey
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.poiskkino.dev"
        components.path = path
        components.queryItems = queryItems
        // Сохраняем буквальный «+» в запросе: некоторые серверы считают его пробелом.
        components.percentEncodedQuery = components.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")
        guard let url = components.url else { throw WatchNextAPIError.invalidURL }

        var request = URLRequest(url: url, timeoutInterval: 30)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("WatchNext-StudentApp/1.0", forHTTPHeaderField: "User-Agent")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            if error.code == .cancelled || Task.isCancelled {
                throw CancellationError()
            }
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw WatchNextAPIError.offline
            case .timedOut:
                throw WatchNextAPIError.timedOut
            default:
                throw WatchNextAPIError.network
            }
        }

        try Task.checkCancellation()
        guard let response = response as? HTTPURLResponse else {
            throw WatchNextAPIError.invalidResponse
        }
        guard response.statusCode == 200 else {
            throw WatchNextAPIError.httpStatus(response.statusCode)
        }

        let value: Value
        do {
            value = try JSONDecoder().decode(Value.self, from: data)
        } catch {
            throw WatchNextAPIError.invalidData
        }
        try Task.checkCancellation()
        return value
    }

}

nonisolated enum WatchNextAPIError: LocalizedError, Sendable {
    case missingKey
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case invalidData
    case offline
    case timedOut
    case network

    var errorDescription: String? {
        switch self {
        case .missingKey:
            return "Добавьте ключ ПоискКино в разделе «Настройки → Ключ API»."
        case .invalidURL:
            return "Не удалось сформировать запрос. Попробуйте ещё раз."
        case .invalidResponse:
            return "ПоискКино вернул неожиданный ответ. Попробуйте ещё раз."
        case .httpStatus(401):
            return "Ключ API не принят. Проверьте его в разделе «Настройки → Ключ API»."
        case .httpStatus(403):
            return "Доступ ограничен: возможно, исчерпан лимит запросов или этот метод недоступен вашему ключу. Проверьте квоту ПоискКино."
        case .httpStatus(429):
            return "Слишком много запросов. Подождите немного и повторите попытку."
        case .httpStatus(let code) where code >= 500:
            return "ПоискКино временно недоступен. Попробуйте позже."
        case .httpStatus(let code):
            return "ПоискКино вернул ошибку HTTP \(code). Попробуйте ещё раз."
        case .invalidData:
            return "Не удалось прочитать данные фильмов. Возможно, формат ответа изменился. Попробуйте позже."
        case .offline:
            return "Проверьте подключение к интернету и повторите попытку."
        case .timedOut:
            return "Сервис не ответил вовремя. Попробуйте ещё раз."
        case .network:
            return "Не удалось подключиться к ПоискКино. Попробуйте ещё раз."
        }
    }
}
