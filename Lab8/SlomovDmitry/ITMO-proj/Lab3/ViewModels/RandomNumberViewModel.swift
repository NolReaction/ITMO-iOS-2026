import Combine

// ViewModel связывает генератор с состоянием экрана
@MainActor // Привязывает работу с этой ViewModel к главному актору, связанному с главным потоком интерфейса
final class RandomNumberViewModel: ObservableObject {
    @Published private(set) var number = 0 // Published свойство сообщает о своих измененияс

    private let generator = NumberGenerator()

    func generateNumber() {
        number = generator.generate()
    }
}
