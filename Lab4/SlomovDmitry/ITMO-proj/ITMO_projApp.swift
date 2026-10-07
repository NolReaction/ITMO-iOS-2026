import SwiftUI
import SwiftData

@main
struct ITMO_projApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Lab4Note.self)
    }
}
