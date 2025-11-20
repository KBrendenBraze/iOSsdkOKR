import BrazeKit
import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        BrazeManager.shared.registerDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        BrazeManager.shared.lastOperationStatus = "APNS registration failed: \(error.localizedDescription)"
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if BrazeManager.shared.handleRemoteNotification(userInfo, completionHandler: completionHandler) {
            return
        }
        completionHandler(.noData)
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        BrazeManager.shared.handleForegroundNotification(notification)
        if #available(iOS 14, *) {
            completionHandler([.list, .banner, .sound])
        } else {
            completionHandler(.alert)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let handled = BrazeManager.shared.handleNotificationResponse(response, completionHandler: completionHandler)
        if !handled {
            completionHandler()
        }
    }
}
