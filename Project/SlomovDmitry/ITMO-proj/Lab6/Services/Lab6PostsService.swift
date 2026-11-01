import Foundation
import Alamofire

// APIClient получает и декодирует JSON. Service готовит результат для приложения.
final class Lab6PostsService: Sendable {
    private let client: Lab6APIClient
    private let baseURL: URL

    init(
        client: Lab6APIClient = Lab6APIClient(),
        baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!
    ) {
        self.client = client
        self.baseURL = baseURL
    }

    func loadPosts(
        completion: @escaping @Sendable (Result<Lab6Response<Lab6PostFeed>, Lab6NetworkError>) -> Void
    ) {
        requestPosts(path: "posts", completion: completion)
    }

    func createPost(
        _ post: Lab6NewPost,
        completion: @escaping @Sendable (Result<Lab6Response<Lab6PostItem>, Lab6NetworkError>) -> Void
    ) {
        client.request(url: baseURL.appendingPathComponent("posts"), method: .post, body: post) {
            (result: Result<Lab6Response<Lab6Post>, Lab6NetworkError>) in
            // Этот callback остаётся на фоновой очереди APIClient.
            completion(result.map { response in
                Lab6Response(
                    value: Lab6PostProcessor.makeItem(from: response.value),
                    diagnostics: response.diagnostics
                )
            })
        }
    }

    func testHTTPError(
        completion: @escaping @Sendable (Result<Lab6Response<Lab6PostFeed>, Lab6NetworkError>) -> Void
    ) {
        requestPosts(path: "posts/999999", completion: completion)
    }

    func testDecodingError(
        completion: @escaping @Sendable (Result<Lab6Response<Lab6PostFeed>, Lab6NetworkError>) -> Void
    ) {
        // Сервер вернёт один объект с HTTP 200. Намеренно ожидаем массив для проверки catch.
        requestPosts(path: "posts/1", completion: completion)
    }

    private func requestPosts(
        path: String,
        completion: @escaping @Sendable (Result<Lab6Response<Lab6PostFeed>, Lab6NetworkError>) -> Void
    ) {
        client.request(url: baseURL.appendingPathComponent(path)) {
            (result: Result<Lab6Response<[Lab6Post]>, Lab6NetworkError>) in
            // Сортировка, нормализация и подсчёт слов тоже выполняются в фоне.
            completion(result.map { response in
                Lab6Response(
                    value: Lab6PostProcessor.makeFeed(from: response.value),
                    diagnostics: response.diagnostics
                )
            })
        }
    }
}
