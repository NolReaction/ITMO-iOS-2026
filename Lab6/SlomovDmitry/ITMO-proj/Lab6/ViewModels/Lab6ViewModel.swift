import Combine
import Dispatch
import Foundation

@MainActor
final class Lab6ViewModel: ObservableObject {
    @Published var newTitle = "Моя первая публикация"
    @Published var newBody = "Проверяю POST запрос из iOS приложения."
    @Published private(set) var feed: Lab6PostFeed?
    @Published private(set) var createdPost: Lab6PostItem?
    @Published private(set) var isBusy = false
    @Published private(set) var statusMessage = "Нажмите GET, чтобы загрузить публикации."
    @Published private(set) var errorMessage: String?
    @Published private(set) var diagnostics: Lab6NetworkDiagnostics?
    @Published private(set) var updatedOnMainThread: Bool?

    private let service: Lab6PostsService

    init(service: Lab6PostsService = Lab6PostsService()) {
        self.service = service
    }

    var canCreate: Bool {
        !isBusy
            && !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !newBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func loadPosts() {
        guard begin("Загружаем публикации…") else { return }
        service.loadPosts { result in
            // Вторая очередь: только обновление состояния интерфейса.
            DispatchQueue.main.async {
                self.finishFeedRequest(result)
            }
        }
    }

    func createPost() {
        guard canCreate else { return }
        let post = Lab6NewPost(
            userId: 1,
            title: newTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            body: newBody.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        guard begin("Отправляем публикацию…") else { return }
        createdPost = nil

        service.createPost(post) { result in
            DispatchQueue.main.async {
                self.isBusy = false
                self.updatedOnMainThread = Thread.isMainThread
                switch result {
                case .success(let response):
                    self.createdPost = response.value
                    self.diagnostics = response.diagnostics
                    self.statusMessage = "POST выполнен. Сервер вернул запись №\(response.value.id)."
                case .failure(let error):
                    self.show(error)
                }
            }
        }
    }

    func testHTTPError() {
        guard begin("Запрашиваем несуществующую запись…") else { return }
        service.testHTTPError { result in
            DispatchQueue.main.async {
                self.finishFeedRequest(result)
            }
        }
    }

    func testDecodingError() {
        guard begin("Проверяем несовпадение структуры JSON…") else { return }
        service.testDecodingError { result in
            DispatchQueue.main.async {
                self.finishFeedRequest(result)
            }
        }
    }

    private func begin(_ message: String) -> Bool {
        guard !isBusy else { return false }
        isBusy = true
        statusMessage = message
        errorMessage = nil
        diagnostics = nil
        updatedOnMainThread = nil
        return true
    }

    private func finishFeedRequest(_ result: Result<Lab6Response<Lab6PostFeed>, Lab6NetworkError>) {
        isBusy = false
        updatedOnMainThread = Thread.isMainThread
        switch result {
        case .success(let response):
            feed = response.value
            diagnostics = response.diagnostics
            statusMessage = response.value.posts.isEmpty
                ? "Сервер вернул пустой список."
                : "Загружено публикаций: \(response.value.posts.count)."
        case .failure(let error):
            // Уже полученные данные остаются на экране при неудачной новой загрузке.
            show(error)
        }
    }

    private func show(_ error: Lab6NetworkError) {
        errorMessage = error.message
        diagnostics = error.diagnostics
        statusMessage = "Запрос завершился с ошибкой (\(error.kind.rawValue))."
    }
}
