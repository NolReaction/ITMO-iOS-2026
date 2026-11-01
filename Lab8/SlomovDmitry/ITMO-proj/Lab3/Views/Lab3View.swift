import SwiftUI

struct Lab3View: View {
    @StateObject private var viewModel = RandomNumberViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("\(viewModel.number)")
                .font(.largeTitle)

            Button("Generate number") {
                viewModel.generateNumber()
            }
            .buttonStyle(.glassProminent)

            NavigationLink("Open second screen") {
                Lab3SecondView()
            }
            .buttonStyle(.glass)
        }
        .controlSize(.large)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background { // оформление под glass ))
            LinearGradient(
                colors: [.blue.opacity(0.18), .cyan.opacity(0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
        .navigationTitle("Lab 3")
    }
}
