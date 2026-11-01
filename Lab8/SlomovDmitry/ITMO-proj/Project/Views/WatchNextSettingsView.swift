import SwiftUI

// Экран настроекк
struct WatchNextSettingsView: View {
    // AppStorage читает и записывает простые настройки в UserDefaults.
    @AppStorage("watchnext.showRatings") private var showRatings = true
    @AppStorage("watchnext.hideFinished") private var hideFinished = false
    @State private var apiKey = ""
    @State private var hasKey = false
    @State private var message: String?

    var body: some View {
        Form {
            Section("Ключ API") {
                Text("Источник — ПоискКино. Для поиска нужен ваш личный ключ API.")
                Link("Получить ключ на сайте ПоискКино",
                     destination: URL(string: "https://poiskkino.dev/")!)
                Text(hasKey ? "Ключ сохранён на устройстве" : "Ключ ещё не добавлен")
                    .foregroundStyle(.secondary)
                SecureField(hasKey ? "Вставьте новый ключ" : "Вставьте ключ API", text: $apiKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .privacySensitive()
                Button("Сохранить ключ") {
                    do {
                        try WatchNextCredentials.save(apiKey)
                        apiKey = ""
                        hasKey = true
                        message = "Ключ сохранён. Вернитесь в каталог и повторите поиск."
                    } catch {
                        message = error.localizedDescription
                    }
                }
                .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                if hasKey {
                    Button("Удалить ключ", role: .destructive) {
                        do {
                            try WatchNextCredentials.delete()
                            apiKey = ""
                            hasKey = false
                            message = "Ключ удалён. Ваш список остался на устройстве."
                        } catch {
                            message = error.localizedDescription
                        }
                    }
                }
                if let message {
                    Text(message).font(.footnote).foregroundStyle(.secondary)
                }
            }
            Section("Предпочтения") {
                Toggle("Показывать рейтинг", isOn: $showRatings)
                Toggle("Скрывать просмотренное", isOn: $hideFinished)
                Button("Сбросить настройки") {
                    showRatings = true
                    hideFinished = false
                }
            }
            Section("О WatchNext") {
                Text("Найдите фильм или сериал, сохраните в свой список и выберите, что посмотреть вечером.")
                Text("Ваш список хранится на этом устройстве. Для загрузки постеров и поиска нужен интернет.")
                    .foregroundStyle(.secondary)
                Link("Данные о фильмах — ПоискКино",
                     destination: URL(string: "https://poiskkino.dev/")!)
                Text("Старые записи из версии 0.1 сохраняют данные TVmaze и исходный язык.")
                    .font(.footnote).foregroundStyle(.secondary)
                Link("TVmaze: источник старых записей (CC BY-SA)",
                     destination: URL(string: "https://www.tvmaze.com/api#licensing")!)
            }
        }
        .scrollContentBackground(.hidden)
        .background { WatchNextBackground() }
        .navigationTitle("Настройки")
        .preferredColorScheme(.dark)
        .tint(.mint)
        .onAppear {
            do {
                hasKey = try WatchNextCredentials.read() != nil
            } catch {
                message = error.localizedDescription
            }
        }
    }
}
