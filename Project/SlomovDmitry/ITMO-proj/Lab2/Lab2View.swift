import SwiftUI

struct Lab2View: View {
    @State private var number = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("\(number)")
                .font(.largeTitle)

            Button("Generate number") {
                number = Int.random(in: 1...100)
            }

            NavigationLink("Open second screen") {
                Lab2SecondView()
            }
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Lab 2")
    }
}
