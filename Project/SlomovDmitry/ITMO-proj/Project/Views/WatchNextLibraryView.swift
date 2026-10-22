import SwiftUI

struct WatchNextLibraryView: View {
    @EnvironmentObject private var library: WatchNextLibraryViewModel
    @AppStorage("watchnext.hideFinished") private var hideFinished = false

    private var visibleEntries: [WatchNextSavedShow] {
        library.entries.filter { !hideFinished || $0.status != .finished }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Мой список,\nмой выбор.")
                    .font(.largeTitle.bold())
                Text("Сохранено: \(library.entries.count)")
                    .foregroundStyle(.secondary)

                Toggle("Скрывать просмотренное", isOn: $hideFinished)
                    .font(.subheadline)

                if let error = library.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }

                if visibleEntries.isEmpty && library.errorMessage == nil {
                    ContentUnavailableView {
                        Label("Место для новой истории", systemImage: "bookmark")
                    } description: {
                        Text(library.entries.isEmpty
                             ? "Откройте каталог и добавьте фильм или сериал в свой список."
                             : "Всё сохранённое скрыто фильтром.")
                    }
                }

                LazyVStack(spacing: 14) {
                    ForEach(visibleEntries) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            NavigationLink {
                                WatchNextShowDetailView(show: entry.show)
                                    .environmentObject(library)
                            } label: {
                                WatchNextShowRow(show: entry.show)
                            }
                            .buttonStyle(.plain)
                            HStack {
                                Image(systemName: entry.status == .finished ? "checkmark.circle.fill" : "bookmark.fill")
                                Text(entry.status.title)
                            }
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.mint)
                            .padding(.horizontal, 12)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background { WatchNextBackground() }
    }
}
