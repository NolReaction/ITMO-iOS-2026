import SwiftUI
import SwiftData

// (Вход в WatchNext и создание вкладок)
@MainActor
struct WatchNextView: View {
    @State private var container: ModelContainer?
    @State private var storageError: String?

    var body: some View {
        Group {
            if let container {
                WatchNextHomeView(
                    context: container.mainContext,
                    sampleShows: WatchNextUITestSupport.catalogShows
                )
                    .modelContainer(container)
            } else if let storageError {
                ContentUnavailableView {
                    Label("Не удалось открыть список", systemImage: "externaldrive.badge.exclamationmark")
                } description: {
                    Text(storageError)
                } actions: {
                    Button("Попробовать ещё раз", action: openStorage)
                        .buttonStyle(.glassProminent)
                }
            } else {
                ProgressView("Открываем WatchNext…")
            }
        }
        .defaultAppStorage(WatchNextUITestSupport.defaults)
        .preferredColorScheme(.dark)
        .environment(\.locale, Locale(identifier: "ru"))
        .tint(.mint)
        .task {
            if container == nil { openStorage() }
        }
    }

    private func openStorage() {
        do {
            let schema = Schema([WatchNextSavedShow.self])
            let configuration: ModelConfiguration
            if WatchNextUITestSupport.isEnabled {
                // Каждый UI-тест получает пустую базу в памяти.
                configuration = ModelConfiguration(
                    "WatchNextUITests",
                    schema: schema,
                    isStoredInMemoryOnly: true,
                    cloudKitDatabase: .none
                )
            } else {
                // Отдельный файл: база Lab4 продолжает работать как раньше.
                let directory = URL.applicationSupportDirectory.appending(
                    path: "WatchNext", directoryHint: .isDirectory
                )
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                configuration = ModelConfiguration(
                    "WatchNext",
                    schema: schema,
                    url: directory.appending(path: "WatchNext.store"),
                    cloudKitDatabase: .none
                )
            }
            container = try ModelContainer(for: schema, configurations: [configuration])
            storageError = nil
        } catch {
            storageError = "Сохранённый список недоступен. Попробуйте открыть его ещё раз."
        }
    }
}

@MainActor
private struct WatchNextHomeView: View {
    @StateObject private var library: WatchNextLibraryViewModel
    private let sampleShows: [WatchNextShow]?

    init(context: ModelContext, sampleShows: [WatchNextShow]? = nil) {
        _library = StateObject(wrappedValue: WatchNextLibraryViewModel(context: context))
        self.sampleShows = sampleShows
    }

    var body: some View {
        TabView {
            WatchNextDiscoverView(sampleShows: sampleShows)
                .tabItem { Label("Каталог", systemImage: "sparkles") }
            WatchNextLibraryView()
                .tabItem { Label("Мой список", systemImage: "bookmark.fill") }
            WatchNextTonightView()
                .tabItem { Label("На вечер", systemImage: "shuffle") }
        }
        .environmentObject(library)
        .navigationTitle("WatchNext")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    WatchNextSettingsView()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("Настройки")
            }
        }
        .alert("Произошла ошибка", isPresented: Binding(
            get: { library.errorMessage != nil },
            set: { if !$0 { library.errorMessage = nil } }
        )) {
            Button("Понятно", role: .cancel) { library.errorMessage = nil }
        } message: {
            Text(library.errorMessage ?? "Попробуйте ещё раз.")
        }
    }
}
