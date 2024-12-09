//
//  AppDelegate.swift
//
//  Copyright © 2023 Zendesk. All rights reserved.
//

import UIKit
import UserNotifications
import ZendeskSDK
import ZendeskSDKMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window : UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications()
        return true
    }

    private func registerForPushNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { allowed, _ in
            guard allowed else { return }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotifications.updatePushNotificationToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        // This checks whether a received push notification should be displayed by Messaging
        let shouldBeDisplayed = PushNotifications.shouldBeDisplayed(userInfo)

        switch shouldBeDisplayed {
        case .messagingShouldDisplay:
            // This push belongs to Messaging and the SDK is able to display it to the end user
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .sound, .badge])
            } else {
                completionHandler([.alert, .sound, .badge])
            }
        case .messagingShouldNotDisplay:
            // This push belongs to Messaging but it should not be displayed to the end user
            completionHandler([])
        case .notFromMessaging:
            // This push does not belong to Messaging
            // If you have push notifications in your app, place your code here

            // If not, just call the `completionHandler`
            completionHandler([])
        @unknown default: break
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // This checks whether a received push notification should be handled by Messaging
        let shouldBeDisplayed = PushNotifications.shouldBeDisplayed(userInfo)

        switch shouldBeDisplayed {
        case .messagingShouldDisplay:
            // This push belongs to Messaging and the SDK is able to handle when the end user interacts with it
            PushNotifications.handleTap(userInfo) { viewController in
               // Handle displaying the returned viewController in here
            }
        case .messagingShouldNotDisplay:
            // This push belongs to Messaging but the interaction should not be handled by the SDK
            break
        case .notFromMessaging:
            // This push does not belong to Messaging
            // If you have push notifications in your app, place your code here

            // If not, just call `break`
            break
        @unknown default: break
        }

        completionHandler()
    }
    
}