import Foundation

struct Lab6NetworkDiagnostics: Sendable {
    let method: String
    let url: String
    let statusCode: Int?
    let data: Data?
    var errorDescription: String?
    var transportErrorCode: Int?
    let handledOnMainThread: Bool

    // На экране показывается только начало большого ответа. data хранится целиком.
    var bodyPreview: String {
        guard let data, !data.isEmpty else { return "Тело ответа отсутствует" }
        let preview = String(decoding: data.prefix(4_000), as: UTF8.self)
        return data.count > 4_000 ? preview + "\n… (показаны первые 4000 байт)" : preview
    }
}

struct Lab6Response<Value: Sendable>: Sendable {
    let value: Value
    let diagnostics: Lab6NetworkDiagnostics
}

struct Lab6NetworkError: LocalizedError, Sendable {
    enum Kind: String, Sendable {
        case transport
        case http
        case decoding
        case invalidResponse
    }

    let kind: Kind
    let message: String
    let diagnostics: Lab6NetworkDiagnostics

    var errorDescription: String? { message }
}
