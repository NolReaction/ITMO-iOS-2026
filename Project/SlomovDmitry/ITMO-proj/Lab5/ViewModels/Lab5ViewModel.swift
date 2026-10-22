import Combine
import Dispatch
import Foundation
import SwiftData

@MainActor
final class Lab5ViewModel: ObservableObject {
    @Published private(set) var noteTexts: [String] = []
    @Published private(set) var statistics: Lab5Statistics? = nil
    @Published private(set) var isProcessing = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var resultReceivedOnMainThread: Bool? = nil

    func loadNotes(context: ModelContext) {
        guard !isProcessing else { return }

        statistics = nil
        resultReceivedOnMainThread = nil
        errorMessage = nil

        let descriptor = FetchDescriptor<Lab4Note>(
            sortBy: [SortDescriptor(\Lab4Note.createdAt, order: .reverse)]
        )

        do {
            let notes = try context.fetch(descriptor)
            noteTexts = notes.map(\.text)
        } catch {
            noteTexts = []
            errorMessage = "Не удалось загрузить заметки. Попробуйте ещё раз."
        }
    }

    func analyzeNotes(useDemoDelay: Bool) {
        guard !isProcessing, !noteTexts.isEmpty else { return }

        // В фоновую очередь передаём строки, а не объекты SwiftData и их контекст.
        let snapshot = noteTexts
        statistics = nil
        resultReceivedOnMainThread = nil
        errorMessage = nil
        isProcessing = true

        // Учебная задержка откладывает старт. Поток на эти 2 секунды не блокируется.
        let delay = useDemoDelay ? 2.0 : 0.0
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) {
            let result = Lab5NoteAnalyzer.analyze(snapshot)

            DispatchQueue.main.async {
                self.statistics = result
                self.resultReceivedOnMainThread = Thread.isMainThread
                self.isProcessing = false
            }
        }
    }
}
