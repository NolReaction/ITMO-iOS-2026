import SwiftUI

struct Lab6View: View {
    @StateObject private var viewModel = Lab6ViewModel()
    @State private var tapCount = 0

    var body: some View {
        List {
            Section("GET: получить публикации") {
                Button("Загрузить публикации") {
                    viewModel.loadPosts()
                }
                .disabled(viewModel.isBusy)
                .accessibilityIdentifier("loadPosts")

                Text("GET /posts • JSONPlaceholder • Alamofire")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Состояние запроса") {
                if viewModel.isBusy {
                    ProgressView(viewModel.statusMessage)
                } else {
                    Text(viewModel.statusMessage)
                }

                if let error = viewModel.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("requestError")
                }
            }

            Section("POST: новая публикация") {
                TextField("Заголовок", text: $viewModel.newTitle)
                    .accessibilityIdentifier("postTitle")
                TextField("Текст публикации", text: $viewModel.newBody, axis: .vertical)
                    .lineLimit(3...6)
                    .accessibilityIdentifier("postBody")
                Button("Отправить POST") {
                    viewModel.createPost()
                }
                .disabled(!viewModel.canCreate)
                .accessibilityIdentifier("createPost")

                Text("Сервер учебный: POST возвращает новую запись, но не сохраняет её для следующих GET-запросов.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let post = viewModel.createdPost {
                Section("Ответ на POST") {
                    Lab6PostRow(post: post)
                }
            }

            Section("Проверка ошибок") {
                Button("Получить HTTP 404") {
                    viewModel.testHTTPError()
                }
                .disabled(viewModel.isBusy)

                Button("Проверить ошибку парсинга JSON") {
                    viewModel.testDecodingError()
                }
                .disabled(viewModel.isBusy)

                Text("Для ошибки сети выключите интернет на устройстве или Mac с симулятором и повторите GET. Ошибка JSON проверяется настоящим ответом: объект вместо массива.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Проверка многопоточности") {
                Button {
                    tapCount += 1
                } label: {
                    Label("Нажатий: \(tapCount)", systemImage: "hand.tap")
                }
                Text("Счётчик доступен во время сетевого запроса. JSON и обработка данных выполняются в фоновой очереди GCD.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if let diagnostics = viewModel.diagnostics {
                    LabeledContent("Поток обработки ответа",
                                   value: diagnostics.handledOnMainThread ? "Главный" : "Фоновый")
                }
                if let isMain = viewModel.updatedOnMainThread {
                    LabeledContent("Поток обновления UI", value: isMain ? "Главный" : "Фоновый")
                }
            }

            if let diagnostics = viewModel.diagnostics {
                Section("Диагностика последнего запроса") {
                    Lab6DiagnosticsView(diagnostics: diagnostics)
                }
            }

            if let feed = viewModel.feed {
                Section("Результат GET: \(feed.posts.count) публикаций") {
                    Text("Всего слов в заголовках и текстах: \(feed.totalWordCount). Пробелы и переносы нормализованы, записи отсортированы по id.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    ForEach(feed.posts) { post in
                        Lab6PostRow(post: post)
                    }
                }
            }
        }
        .navigationTitle("Lab 6: Сеть")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct Lab6PostRow: View {
    let post: Lab6PostItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(post.title).font(.headline)
            Text(post.body).font(.subheadline)
            Text("№\(post.id) • Автор \(post.userId) • Слов: \(post.wordCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
