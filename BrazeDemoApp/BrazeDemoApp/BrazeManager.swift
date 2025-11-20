import BrazeKit
import BrazeKitCompat
import BrazeUI
import SwiftUI
import UIKit
import UserNotifications

@MainActor
final class BrazeManager: NSObject, ObservableObject {
    static let shared = BrazeManager()

    @Published var currentUserId: String
    @Published var contentCards: [Braze.ContentCard] = []
    @Published var lastOperationStatus: String = ""
    @Published var isPushAuthorized: Bool = false

    private(set) var braze: Braze
    private var cardsSubscription: Braze.Cancellable?

    private override init() {
        let settings = BrazeManager.loadConfiguration()

        var configuration = Braze.Configuration(apiKey: settings.apiKey, endpoint: settings.endpoint)
        configuration.logger.level = .info
        configuration.push.automation = true
        configuration.sessionTimeout = 60

        let brazeInstance = Braze(configuration: configuration)
        brazeInstance.inAppMessagePresenter = BrazeInAppMessageUI.Presenter()
        BrazeKitCompat.provide(braze: brazeInstance)

        currentUserId = settings.defaultUserId
        braze = brazeInstance

        super.init()

        braze.changeUser(currentUserId)
        cardsSubscription = braze.contentCards.subscribeToUpdates { [weak self] cards in
            guard let self else { return }
            Task { @MainActor in
                self.contentCards = cards
                self.lastOperationStatus = "Received \(cards.count) content cards"
            }
        }
    }

    deinit {
        cardsSubscription?.cancel()
    }

    func changeUser(to userId: String) {
        guard !userId.isEmpty else { return }
        currentUserId = userId
        braze.changeUser(userId)
        lastOperationStatus = "Changed user to \(userId)"
    }

    func logCustomEvent(name: String, properties: [String: Any] = [:]) {
        var eventProperties = Braze.Properties()
        properties.forEach { key, value in
            switch value {
            case let intValue as Int:
                eventProperties[key] = intValue
            case let doubleValue as Double:
                eventProperties[key] = doubleValue
            case let boolValue as Bool:
                eventProperties[key] = boolValue
            case let stringValue as String:
                eventProperties[key] = stringValue
            default:
                break
            }
        }
        braze.logCustomEvent(name: name, properties: eventProperties)
        lastOperationStatus = "Logged custom event \(name)"
    }

    func logPurchase(productIdentifier: String, currency: String, price: Double) {
        braze.logPurchase(productId: productIdentifier, currency: currency, price: price)
        lastOperationStatus = "Logged purchase of \(productIdentifier)"
    }

    func refreshContentCards() {
        braze.contentCards.requestRefresh { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let cards):
                    self?.contentCards = cards
                    self?.lastOperationStatus = "Fetched \(cards.count) content cards"
                case .failure(let error):
                    self?.lastOperationStatus = "Content cards error: \(error.localizedDescription)"
                }
            }
        }
    }

    func triggerInAppMessageSync() {
        braze.requestImmediateDataFlush()
        Appboy.sharedInstance()?.inAppMessageController.displayNextInAppMessage()
        lastOperationStatus = "Asked Braze to display the next in-app message"
    }

    func flushNow() {
        braze.requestImmediateDataFlush()
        lastOperationStatus = "Requested immediate data flush"
    }

    func updateCustomAttribute(key: String, value: String) {
        braze.user.setCustomAttribute(key: key, value: value)
        lastOperationStatus = "Set custom attribute \(key)"
    }

    func requestPushAuthorization() async {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound, .provisional])
            await MainActor.run {
                self.isPushAuthorized = granted
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            lastOperationStatus = granted ? "Push permission granted" : "Push permission denied"
        } catch {
            lastOperationStatus = "Push permission error: \(error.localizedDescription)"
        }
    }

    func registerDeviceToken(_ deviceToken: Data) {
        braze.notifications.register(deviceToken: deviceToken)
        lastOperationStatus = "Registered device token with Braze"
    }

    func handleRemoteNotification(_ userInfo: [AnyHashable: Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        braze.notifications.handleBackgroundNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }

    func handleNotificationResponse(_ response: UNNotificationResponse, completionHandler: @escaping () -> Void) -> Bool {
        braze.notifications.handleUserNotification(response: response, withCompletionHandler: completionHandler)
    }

    func handleForegroundNotification(_ notification: UNNotification) {
        braze.notifications.handleForegroundNotification(notification: notification)
    }

    private static func loadConfiguration() -> BrazeConfiguration {
        let bundle = Bundle.main
        let candidateFiles = ["BrazeConfiguration", "BrazeConfiguration.example"]

        for candidate in candidateFiles {
            if let url = bundle.url(forResource: candidate, withExtension: "plist"),
               let data = try? Data(contentsOf: url),
               let configuration = try? PropertyListDecoder().decode(BrazeConfiguration.self, from: data) {
                return configuration
            }
        }

        return BrazeConfiguration(apiKey: "YOUR-API-KEY", endpoint: "YOUR-ENDPOINT", defaultUserId: "example-user")
    }
}

struct BrazeConfiguration: Codable {
    let apiKey: String
    let endpoint: String
    let defaultUserId: String
}
