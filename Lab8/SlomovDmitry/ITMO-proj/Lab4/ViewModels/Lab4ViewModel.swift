import Combine
import Foundation
import SwiftData

@MainActor
final class Lab4ViewModel: ObservableObject {
    @Published private(set) var notes: [Lab4Note] = []
    @Published private(set) var showDates = true
    @Published private(set) var hasSavedSettings = false
    @Published private(set) var errorMessage: String? = nil

    private let defaults = UserDefaults.standard
    private let showDatesKey = "lab4.showDates"

    init() {
        if let savedValue = defaults.object(forKey: showDatesKey) as? Bool {
            showDates = savedValue
            hasSavedSettings = true
        }
    }

    func loadNotes(context: ModelContext) {
        let descriptor = FetchDescriptor<Lab4Note>(
            sortBy: [SortDescriptor(\Lab4Note.createdAt, order: .reverse)]
        )

        do {
            notes = try context.fetch(descriptor)
            errorMessage = nil
        } catch {
            notes = []
            errorMessage = "Unable to load notes: \(error.localizedDescription)"
        }
    }

    func addNote(text: String, context: ModelContext) -> Bool {
        guard let text = cleanedText(text) else { return false }
        context.insert(Lab4Note(text: text))
        return saveChanges(context: context)
    }

    func updateNote(_ note: Lab4Note, text: String, context: ModelContext) -> Bool {
        guard let text = cleanedText(text) else { return false }
        note.text = text
        return saveChanges(context: context)
    }

    func deleteNote(_ note: Lab4Note, context: ModelContext) -> Bool {
        context.delete(note)
        return saveChanges(context: context)
    }

    func setShowDates(_ value: Bool) {
        defaults.set(value, forKey: showDatesKey)
        showDates = value
        hasSavedSettings = true
    }

    func resetSettings() {
        defaults.removeObject(forKey: showDatesKey)
        showDates = true
        hasSavedSettings = false
    }

    private func cleanedText(_ text: String) -> String? {
        let result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !result.isEmpty else {
            errorMessage = "Enter some text for the note."
            return nil
        }
        return result
    }

    private func saveChanges(context: ModelContext) -> Bool {
        do {
            try context.save()
        } catch {
            context.rollback()
            errorMessage = "Unable to save notes: \(error.localizedDescription)"
            return false
        }

        loadNotes(context: context)
        return true
    }
}
