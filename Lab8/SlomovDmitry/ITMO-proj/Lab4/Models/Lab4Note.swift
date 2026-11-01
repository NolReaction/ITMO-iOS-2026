import Foundation
import SwiftData

@Model
final class Lab4Note {
    var text: String
    var createdAt: Date

    init(text: String) {
        self.text = text
        self.createdAt = Date()
    }
}
