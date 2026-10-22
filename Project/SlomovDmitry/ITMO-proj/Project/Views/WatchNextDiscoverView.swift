import SwiftUI

struct WatchNextDiscoverView: View {
    @EnvironmentObject private var library: WatchNextLibraryViewModel
    // Управление загрузкой
    @StateObject private var viewModel = WatchNextCatalogViewModel()
    // Текст, который я ввожу
    @State private var searchText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ВАША СЛЕДУЮЩАЯ ИСТОРИЯ")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.mint)
                    Text("Что посмотрим\nсегодня?")
                        .font(.largeTitle.bold())
                    Text("Найдите фильм или сериал и сохраните в свой список.")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    TextField("Поиск: например, Интерстеллар", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                        .onSubmit { search() }
                        .disabled(viewModel.isLoading)
                    Button(action: search) {
                        Image(systemName: "magnifyingglass")
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(viewModel.isLoading)
                    .accessibilityLabel("Поиск")
                }
                .padding(12)
                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))

                if viewModel.isLoading {
                    ProgressView("Ищем фильмы и сериалы…")
                        .frame(maxWidth: .infinity)
                        .padding()
                }

                if let error = viewModel.errorMessage {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(error, systemImage: "exclamationmark.circle")
                            .foregroundStyle(.secondary)
                        Button("Попробовать ещё раз", action: search)
                            .buttonStyle(.glass)
                            .disabled(viewModel.isLoading)
                        NavigationLink("Открыть настройки") {
                            WatchNextSettingsView()
                        }
                    }
                }

                HStack {
                    Text(viewModel.loadedQuery.isEmpty ? "Фильмы и сериалы" : "Результаты поиска")
                        .font(.title2.bold())
                    Spacer()
                    if !viewModel.loadedQuery.isEmpty {
                        Button("Открыть каталог") {
                            searchText = ""
                            search()
                        }
                        .disabled(viewModel.isLoading)
                    }
                }

                if viewModel.shows.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    ContentUnavailableView("Ничего не найдено", systemImage: "magnifyingglass",
                                           description: Text("Попробуйте другое название или загрузите каталог ещё раз."))
                }

                LazyVStack(spacing: 12) {
                    ForEach(viewModel.shows, id: \.catalogID) { show in
                        NavigationLink {
                            WatchNextShowDetailView(show: show)
                                .environmentObject(library)
                        } label: {
                            WatchNextShowRow(show: show)
                        }
                        .buttonStyle(.plain)
                    }
                }
                if !viewModel.shows.isEmpty {
                    Text("Показываем до 30 результатов. Если нужного нет, уточните название.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
        }
        .background { WatchNextBackground() }
        .task { await viewModel.loadIfNeeded(query: searchText) }
    }

    private func search() {
        Task { await viewModel.load(query: searchText) }
    }
}
