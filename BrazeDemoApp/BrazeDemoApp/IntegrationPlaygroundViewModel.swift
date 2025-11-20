import Foundation

@MainActor
final class IntegrationPlaygroundViewModel: ObservableObject {
    @Published var logs: [String] = []

    func changeUser(to userId: String) {
        record("Tap into Braze's changeUser() with id: \(userId)")
    }

    func identifyUser(firstName: String, lastName: String, email: String) {
        record("Populate user profile fields (first: \(firstName), last: \(lastName), email: \(email)) via Braze's public user API.")
    }

    func setCustomAttribute(key: String, value: String) {
        record("Set custom attribute '\(key)' = '\(value)' using Braze's custom attribute setter.")
    }

    func logCustomEvent(name: String, propertyKey: String?, propertyValue: String?) {
        var details = "Log custom event '\(name)'"
        if let key = propertyKey, !key.isEmpty, let value = propertyValue, !value.isEmpty {
            details.append(" with property \(key)=\(value)")
        }
        record(details + " using Braze's logCustomEvent.")
    }

    func registerForPush() {
        record("Request push permissions, register the device token, and pass it to Braze when ready.")
    }

    func requestContentCards() {
        record("Call Braze's Content Cards refresh + listener APIs.")
    }

    func requestInAppMessage() {
        record("Trigger an in-app message sync using Braze's in-app message presenter.")
    }

    func flushData() {
        record("Invoke Braze's requestImmediateDataFlush() to send data right away.")
    }

    func resetLog() {
        logs.removeAll()
        record("Cleared local log. Hook this to any cleanup you need before testing again.")
    }

    private func record(_ message: String) {
        let timestamp = Self.dateFormatter.string(from: Date())
        logs.insert("[\(timestamp)] \(message)", at: 0)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss"
        return formatter
    }()
}
