import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Lab 6: Сеть") {
                    Lab6View()
                }
            }
            .navigationTitle("Лабораторная 6")
        }
    }
}
