import Foundation

nonisolated enum Lab5NoteAnalyzer {
    static func analyze(_ texts: [String]) -> Lab5Statistics {
        var wordCount = 0
        var characterCount = 0

        for text in texts {
            wordCount += text.split(whereSeparator: { $0.isWhitespace }).count
            characterCount += text.count
        }

        return Lab5Statistics(
            noteCount: texts.count,
            wordCount: wordCount,
            characterCount: characterCount,
            calculatedOnMainThread: Thread.isMainThread
        )
    }
}
