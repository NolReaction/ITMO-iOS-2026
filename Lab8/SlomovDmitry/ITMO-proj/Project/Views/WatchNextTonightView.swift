import SwiftUI

// Экран «На вечер»
struct WatchNextTonightView: View {
    @EnvironmentObject private var library: WatchNextLibraryViewModel
    @State private var selectedGenre = "Все жанры"
    @State private var pickedShow: WatchNextShow?

    private var plannedShows: [WatchNextShow] {
        library.entries.filter { $0.status == .planned }.map { $0.show }
    }

    private var availableGenres: [String] {
        ["Все жанры"] + WatchNextRules.genres(in: plannedShows)
    }

    private var candidates: [WatchNextShow] {
        WatchNextRules.filter(plannedShows, genre: selectedGenre)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.mint)
                Text("Что выбрать\nна вечер?")
                    .font(.largeTitle.bold())
                Text("Случайный выбор из списка «Хочу посмотреть».")
                    .foregroundStyle(.secondary)

                Picker("Жанр", selection: $selectedGenre) {
                    ForEach(availableGenres, id: \.self) { genre in
                        Text(genre).tag(genre)
                    }
                }
                .pickerStyle(.menu)

                // Кнопочка с обработкой нажатия (WatchNextRules.pick)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        pickedShow = WatchNextRules.pick(from: candidates, excluding: pickedShow?.catalogID)
                    }
                } label: {
                    Label(pickedShow == nil ? "Выбрать на вечер" : "Выбрать другое", systemImage: "shuffle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .disabled(candidates.isEmpty)

                if let pickedShow {
                    NavigationLink {
                        WatchNextShowDetailView(show: pickedShow)
                            .environmentObject(library)
                    } label: {
                        WatchNextShowRow(show: pickedShow)
                    }
                    .buttonStyle(.plain)
                    Text("Нажмите на карточку, чтобы узнать подробности.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else if candidates.isEmpty {
                    ContentUnavailableView(
                        "Добавьте что-нибудь в список",
                        systemImage: "sparkles",
                        description: Text("Сначала сохраните фильм или сериал со статусом «Хочу посмотреть».")
                    )
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background { WatchNextBackground() }
        .onChange(of: selectedGenre) { _, _ in pickedShow = nil }
        .onChange(of: plannedShows.map { $0.catalogID }) { _, _ in
            if !availableGenres.contains(selectedGenre) { selectedGenre = "Все жанры" }
            if let pickedShow, !candidates.contains(where: { $0.catalogID == pickedShow.catalogID }) {
                self.pickedShow = nil
            }
        }
    }
}
