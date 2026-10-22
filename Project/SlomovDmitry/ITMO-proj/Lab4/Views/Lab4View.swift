import SwiftUI
import SwiftData

struct Lab4View: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = Lab4ViewModel()
    @State private var draftText = ""
    @State private var editingNote: Lab4Note? = nil

    var body: some View {
        List {
            Section(editingNote == nil ? "New note" : "Edit note") {
                TextField("Note text", text: $draftText, axis: .vertical)
                    .lineLimit(1...4)

                HStack {
                    Button(editingNote == nil ? "Add note" : "Save changes") {
                        saveNote()
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    if editingNote != nil {
                        Button("Cancel") {
                            clearEditor()
                        }
                        .buttonStyle(.glass)
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section("Settings") {
                Toggle("Show creation dates", isOn: Binding(
                    get: { viewModel.showDates },
                    set: { viewModel.setShowDates($0) }
                ))

                Button("Reset settings") {
                    viewModel.resetSettings()
                }
                .disabled(!viewModel.hasSavedSettings)
            }

            Section("Notes (\(viewModel.notes.count))") {
                if viewModel.notes.isEmpty {
                    Text("Add your first note above.")
                        .foregroundStyle(.secondary)
                }

                ForEach(viewModel.notes) { note in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.text)

                            if viewModel.showDates {
                                Text(note.createdAt, format: .dateTime.day().month().year().hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        Button {
                            editingNote = note
                            draftText = note.text
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("Edit note")

                        Button(role: .destructive) {
                            deleteNote(note)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("Delete note")
                    }
                }
            }
        }
        .navigationTitle("Lab 4")
        .onAppear {
            viewModel.loadNotes(context: modelContext)
        }
    }

    private func saveNote() {
        let saved: Bool
        if let editingNote = editingNote {
            saved = viewModel.updateNote(editingNote, text: draftText, context: modelContext)
        } else {
            saved = viewModel.addNote(text: draftText, context: modelContext)
        }

        if saved {
            clearEditor()
        }
    }

    private func deleteNote(_ note: Lab4Note) {
        let wasEditing = editingNote === note
        if viewModel.deleteNote(note, context: modelContext) && wasEditing {
            clearEditor()
        }
    }

    private func clearEditor() {
        draftText = ""
        editingNote = nil
    }
}
