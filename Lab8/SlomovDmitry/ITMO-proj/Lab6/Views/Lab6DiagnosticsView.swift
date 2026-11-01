import SwiftUI

struct Lab6DiagnosticsView: View {
    let diagnostics: Lab6NetworkDiagnostics

    var body: some View {
        LabeledContent("Метод", value: diagnostics.method)
        Text(diagnostics.url)
            .font(.caption)
            .textSelection(.enabled)

        LabeledContent("code (HTTP)", value: diagnostics.statusCode.map { String($0) } ?? "Нет HTTP-ответа")
        if let transportCode = diagnostics.transportErrorCode {
            LabeledContent("Код ошибки URL", value: String(transportCode))
        }
        LabeledContent("data", value: "\(diagnostics.data?.count ?? 0) байт")

        DisclosureGroup("error: \(diagnostics.errorDescription == nil ? "nil" : "есть ошибка")") {
            Text(diagnostics.errorDescription ?? "Ошибка отсутствует")
                .font(.caption.monospaced())
                .textSelection(.enabled)
        }
        DisclosureGroup("data: тело ответа") {
            Text(diagnostics.bodyPreview)
                .font(.caption.monospaced())
                .textSelection(.enabled)
        }
    }
}
