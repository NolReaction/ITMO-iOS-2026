import SwiftUI
import SwiftData

struct Lab5View: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = Lab5ViewModel()
    @AppStorage("lab5.demoDelay") private var useDemoDelay = true
    @State private var tapCount = 0

    var body: some View {
        List {
            Section("Данные из Lab4") {
                LabeledContent("Заметок загружено", value: "\(viewModel.noteTexts.count)")
                NavigationLink("Открыть заметки Lab4") {
                    Lab4View()
                }
                .disabled(viewModel.isProcessing)

                if viewModel.noteTexts.isEmpty {
                    Text("Добавьте пару заметок в Lab4 и вернитесь сюда.")
                        .foregroundStyle(.secondary)
                }
                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(.red)
                    Button("Повторить загрузку") {
                        viewModel.loadNotes(context: modelContext)
                    }
                }
            }

            Section("Фоновый анализ") {
                Toggle("Учебная задержка: 2 секунды", isOn: $useDemoDelay)
                    .disabled(viewModel.isProcessing)
                Text("Задержка откладывает запуск, чтобы успеть проверить интерфейс. Сам подсчёт небольших заметок быстрый.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Посчитать статистику") {
                    viewModel.analyzeNotes(useDemoDelay: useDemoDelay)
                }
                .buttonStyle(.glassProminent)
                .disabled(viewModel.isProcessing || viewModel.noteTexts.isEmpty)

                if viewModel.isProcessing {
                    ProgressView("Ожидаем результат…")
                }
            }

            Section("Проверка интерфейса") {
                Button {
                    tapCount += 1
                } label: {
                    Label("Нажатий: \(tapCount)", systemImage: "hand.tap")
                }
                .buttonStyle(.glass)

                Text("Нажимайте эту кнопку, пока ожидается результат. Счётчик продолжает работать.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let statistics = viewModel.statistics {
                Section("Результат") {
                    LabeledContent("Заметки", value: "\(statistics.noteCount)")
                    LabeledContent("Слова", value: "\(statistics.wordCount)")
                    LabeledContent("Символы с пробелами", value: "\(statistics.characterCount)")
                    LabeledContent("Поток расчёта",
                                   value: statistics.calculatedOnMainThread ? "Главный" : "Фоновый")
                    LabeledContent("Поток показа результата",
                                   value: viewModel.resultReceivedOnMainThread == true ? "Главный" : "Фоновый")
                    Text("Потоки проверены через Thread.isMainThread. Статистика относится к снимку заметок на момент запуска.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Lab 5: Многопоточность")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadNotes(context: modelContext)
        }
    }
}
