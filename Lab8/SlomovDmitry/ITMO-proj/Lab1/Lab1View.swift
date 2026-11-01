import SwiftUI

struct Lab1View: View {
    var body: some View {
        VStack(spacing: 16) {
            Button("Task 1: Orders") {
                runTask1()
            }

            Button("Task 2: Geometry") {
                runTask2()
            }

            Button("Task 3: Priority queue") {
                runTask3()
            }

            Button("Run all tasks") {
                runTask1()
                runTask2()
                runTask3()
            }

            Text("Results are printed in the Xcode console.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .navigationTitle("Lab 1")
    }
}
