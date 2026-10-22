import SwiftUI

// Экран подробностей выбранного фильма
struct WatchNextShowDetailView: View {
    let show: WatchNextShow
    @EnvironmentObject private var library: WatchNextLibraryViewModel
    @AppStorage("watchnext.showRatings") private var showRatings = true
    @State private var confirmRemoval = false

    private var savedEntry: WatchNextSavedShow? {
        library.entry(for: show)
    }

    // Каждый раз читаем актуальную запись из библиотеки.
    private var statusBinding: Binding<WatchNextStatus> {
        Binding(
            get: { library.entry(for: show)?.status ?? .planned },
            set: { status in
                if let entry = library.entry(for: show) {
                    _ = library.updateStatus(status, for: entry)
                }
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(spacing: 16) {
                    WatchNextPosterView(url: show.imageURL, width: 160, height: 225)
                        .shadow(color: .black.opacity(0.3), radius: 18, y: 8)

                    Text(show.name)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)

                    HStack(spacing: 16) {
                        Text("\(show.kindTitle) · \(show.year)").foregroundStyle(.secondary)
                        if showRatings, show.rating?.average != nil {
                            Label(show.ratingText, systemImage: "star.fill")
                                .foregroundStyle(.mint)
                        }
                    }
                    .font(.subheadline)

                    if !show.genres.isEmpty {
                        Text(show.genres.joined(separator: " · "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)

                if let error = library.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }

                if savedEntry != nil {
                    VStack(alignment: .leading, spacing: 14) {
                        Label("В моём списке", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.mint)

                        Picker("Статус", selection: statusBinding) {
                            ForEach(WatchNextStatus.allCases, id: \.self) { status in
                                Text(status.title).tag(status)
                            }
                        }
                        .pickerStyle(.menu)

                        Button("Удалить из моего списка", role: .destructive) {
                            confirmRemoval = true
                        }
                        .buttonStyle(.glass)
                    }
                } else {
                    Button {
                        _ = library.add(show)
                    } label: {
                        Label("Добавить в мой список", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Описание").font(.title2.bold())
                    Text(show.overview)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.88))
                        .lineSpacing(5)
                        .textSelection(.enabled)
                }

                if let sourceURL = URL(string: show.url) {
                    Link(destination: sourceURL) {
                        Label("Открыть страницу", systemImage: "arrow.up.right.square")
                    }
                    .buttonStyle(.glass)
                }
            }
            .padding(20)
            .padding(.bottom, 12)
        }
        .background(WatchNextBackground())
        .navigationTitle("Подробности")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .tint(.mint)
        .confirmationDialog("Удалить из моего списка?",
                            isPresented: $confirmRemoval,
                            titleVisibility: .visible) {
            Button("Удалить из моего списка", role: .destructive) {
                if let entry = savedEntry {
                    _ = library.remove(entry)
                }
            }
            Button("Отмена", role: .cancel) {}
        }
    }
}
