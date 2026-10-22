import Combine
import Foundation
import SwiftData

// Личная библиотека - управление сохранённым списком
@MainActor
final class WatchNextLibraryViewModel: ObservableObject {
    @Published private(set) var entries: [WatchNextSavedShow] = []
    @Published var errorMessage: String?

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        reload()
    }

    func reload() {
        let descriptor = FetchDescriptor<WatchNextSavedShow>(
            sortBy: [SortDescriptor(\WatchNextSavedShow.addedAt, order: .reverse)]
        )

        do {
            entries = try context.fetch(descriptor)
        } catch {
            entries = []
            errorMessage = "Не удалось прочитать сохранённый список. Попробуйте открыть WatchNext заново."
        }
    }

    func entry(for show: WatchNextShow) -> WatchNextSavedShow? {
        entries.first { $0.catalogID == show.catalogID }
    }

    @discardableResult
    func add(_ show: WatchNextShow) -> Bool {
        if entry(for: show) != nil {
            errorMessage = nil
            return true
        }

        context.insert(WatchNextSavedShow(show: show))
        return saveChanges()
    }

    @discardableResult
    func updateStatus(_ status: WatchNextStatus, for entry: WatchNextSavedShow) -> Bool {
        entry.status = status
        return saveChanges()
    }

    @discardableResult
    func remove(_ entry: WatchNextSavedShow) -> Bool {
        context.delete(entry)
        return saveChanges()
    }

    private func saveChanges() -> Bool {
        do {
            try context.save()
        } catch {
            context.rollback()
            errorMessage = "Не удалось сохранить изменения. Проверьте свободное место на устройстве и попробуйте ещё раз."
            return false
        }

        errorMessage = nil
        reload()
        return true
    }
}
