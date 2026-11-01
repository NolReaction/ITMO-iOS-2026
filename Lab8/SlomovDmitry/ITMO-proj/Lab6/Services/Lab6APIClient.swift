import Alamofire
import Dispatch
import Foundation

// Сетевой слой не знает ни о SwiftUI, ни о ViewModel.
final class Lab6APIClient: Sendable {
    private let session: Session
    private let processingQueue = DispatchQueue(
        label: "com.slomov.lab6.response-processing",
        qos: .userInitiated
    )

    init(session: Session? = nil) {
        let configuration = URLSessionConfiguration.ephemeral
        // Для учебной проверки каждый GET идёт в сеть, а не в локальный URLCache.
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 20
        self.session = session ?? Session(configuration: configuration)
    }

    func request<Value: Decodable & Sendable>(
        url: URL,
        method: HTTPMethod = .get,
        body: Lab6NewPost? = nil,
        completion: @escaping @Sendable (Result<Lab6Response<Value>, Lab6NetworkError>) -> Void
    ) {
        let request: DataRequest

        if let body {
            request = session.request(
                url,
                method: method,
                parameters: body,
                encoder: JSONParameterEncoder.default
            )
        } else {
            request = session.request(url, method: method)
        }

        request
            .validate(statusCode: 200..<300)
            .responseData(queue: processingQueue) { response in
                // Три отдельные части ответа: error, HTTP code и data.
                let error = response.error
                let code = response.response?.statusCode
                let data = response.data

                var diagnostics = Lab6NetworkDiagnostics(
                    method: method.rawValue,
                    url: url.absoluteString,
                    statusCode: code,
                    data: data,
                    errorDescription: error?.localizedDescription,
                    transportErrorCode: nil,
                    handledOnMainThread: Thread.isMainThread
                )

                // Ответ с HTTP 404 дошёл по сети, но сама операция неуспешна.
                if let code, !(200..<300).contains(code) {
                    completion(.failure(Lab6NetworkError(
                        kind: .http,
                        message: "Сервер вернул HTTP \(code).",
                        diagnostics: diagnostics
                    )))
                    return
                }

                // Например: нет интернета или закончился тайм-аут.
                if let error {
                    let urlError = error.underlyingError as? URLError
                    diagnostics.transportErrorCode = urlError?.errorCode
                    let message: String
                    switch urlError?.code {
                    case .notConnectedToInternet:
                        message = "Нет подключения к интернету. Проверьте сеть и повторите запрос."
                    case .timedOut:
                        message = "Сервер не ответил вовремя. Повторите запрос."
                    case .networkConnectionLost:
                        message = "Соединение прервалось. Повторите запрос."
                    default:
                        message = "Не удалось выполнить запрос: \(error.localizedDescription)"
                    }
                    // Ошибка сериализации пустого body тоже может прийти от Alamofire.
                    let kind: Lab6NetworkError.Kind = error.isResponseSerializationError
                        ? .invalidResponse : .transport
                    completion(.failure(Lab6NetworkError(
                        kind: kind,
                        message: message,
                        diagnostics: diagnostics
                    )))
                    return
                }

                guard code != nil, let data, !data.isEmpty else {
                    diagnostics.errorDescription = "Ожидался HTTP-ответ с непустым JSON."
                    completion(.failure(Lab6NetworkError(
                        kind: .invalidResponse,
                        message: "Сервер не прислал ожидаемый HTTP-ответ с данными.",
                        diagnostics: diagnostics
                    )))
                    return
                }

                do {
                    // Этот callback выполняется на processingQueue, не на главном потоке.
                    let value = try JSONDecoder().decode(Value.self, from: data)
                    completion(.success(Lab6Response(value: value, diagnostics: diagnostics)))
                } catch {
                    diagnostics.errorDescription = String(describing: error)
                    completion(.failure(Lab6NetworkError(
                        kind: .decoding,
                        message: "Ответ получен, но структура JSON не соответствует модели.",
                        diagnostics: diagnostics
                    )))
                }
            }
    }
}
