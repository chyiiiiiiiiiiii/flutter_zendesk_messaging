import UIKit
import ZendeskSDKMessaging
import ZendeskSDK
import UserNotifications

public class ZendeskMessaging: NSObject {
    private static let unreadMessages = "unread_messages"
    private static let zendeskEvent = "zendesk_event"

    let TAG = "[ZendeskMessaging]"

    private weak var zendeskPlugin: SwiftZendeskMessagingPlugin?
    private let channel: FlutterMethodChannel
    private var lastConnectionStatus: String = "unknown"

    init(flutterPlugin: SwiftZendeskMessagingPlugin, channel: FlutterMethodChannel) {
        self.zendeskPlugin = flutterPlugin
        self.channel = channel
    }

    func initialize(channelKey: String, flutterResult: @escaping FlutterResult) {
        print("\(self.TAG) - Channel Key - \(channelKey)\n")
        Zendesk.initialize(withChannelKey: channelKey, messagingFactory: DefaultMessagingFactory()) { result in
            DispatchQueue.main.async {
                if case let .failure(error) = result {
                    self.zendeskPlugin?.isInitialized = false
                    print("\(self.TAG) - initialize failure - \(error.localizedDescription)\n")
                    flutterResult(FlutterError(
                        code: "initialize_error",
                        message: error.localizedDescription,
                        details: nil)
                    )
                } else {
                    self.zendeskPlugin?.isInitialized = true
                    print("\(self.TAG) - initialize success")
                    flutterResult(nil)
                }
            }
        }
    }

    func invalidate() {
        Zendesk.instance?.removeEventObserver(self)
        Zendesk.invalidate()
        self.zendeskPlugin?.isInitialized = false
        self.zendeskPlugin?.isLoggedIn = false
        print("\(self.TAG) - invalidate")
    }

    func show(rootViewController: UIViewController?, flutterResult: @escaping FlutterResult) {
        guard let viewController = Zendesk.instance?.messaging?.messagingViewController() else {
            print("\(self.TAG) - Unable to create Zendesk messaging view controller")
            flutterResult(FlutterError(
                code: "show_error",
                message: "Unable to create Zendesk messaging view controller",
                details: nil)
            )
            return
        }
        guard let rootViewController = rootViewController else {
            print("\(self.TAG) - Root view controller is nil")
            flutterResult(FlutterError(
                code: "show_error",
                message: "Root view controller is nil",
                details: nil)
            )
            return
        }

        let navController = UINavigationController(rootViewController: viewController)

        DispatchQueue.main.async {
            if let presentedVC = rootViewController.presentedViewController {
                if presentedVC !== navController {
                    presentedVC.dismiss(animated: true) {
                        rootViewController.present(navController, animated: true, completion: nil)
                    }
                } else {
                    print("\(self.TAG) - Zendesk messaging view controller is already presented")
                }
            } else {
                rootViewController.present(navController, animated: true, completion: nil)
            }
            flutterResult(nil)
        }
        print("\(self.TAG) - show")
    }

    func showConversation(conversationId: String, rootViewController: UIViewController?, flutterResult: @escaping FlutterResult) {
        guard let viewController = Zendesk.instance?.messaging?.messagingViewController(
            .showConversation(conversationId: conversationId, exitAction: .returnToConversationList)
        ) else {
            print("\(self.TAG) - Unable to create Zendesk messaging view controller for conversation")
            flutterResult(FlutterError(
                code: "show_error",
                message: "Unable to create Zendesk messaging view controller for conversation",
                details: nil)
            )
            return
        }
        guard let rootViewController = rootViewController else {
            print("\(self.TAG) - Root view controller is nil")
            flutterResult(FlutterError(
                code: "show_error",
                message: "Root view controller is nil",
                details: nil)
            )
            return
        }

        let navController = UINavigationController(rootViewController: viewController)

        DispatchQueue.main.async {
            if let presentedVC = rootViewController.presentedViewController {
                presentedVC.dismiss(animated: true) {
                    rootViewController.present(navController, animated: true, completion: nil)
                }
            } else {
                rootViewController.present(navController, animated: true, completion: nil)
            }
            flutterResult(nil)
        }
        print("\(self.TAG) - showConversation: \(conversationId)")
    }

    func showConversationList(rootViewController: UIViewController?, flutterResult: @escaping FlutterResult) {
        guard let viewController = Zendesk.instance?.messaging?.messagingViewController(
            .showConversationList
        ) else {
            print("\(self.TAG) - Unable to create Zendesk conversation list view controller")
            flutterResult(FlutterError(
                code: "show_error",
                message: "Unable to create Zendesk conversation list view controller",
                details: nil)
            )
            return
        }
        guard let rootViewController = rootViewController else {
            print("\(self.TAG) - Root view controller is nil")
            flutterResult(FlutterError(
                code: "show_error",
                message: "Root view controller is nil",
                details: nil)
            )
            return
        }

        let navController = UINavigationController(rootViewController: viewController)

        DispatchQueue.main.async {
            if let presentedVC = rootViewController.presentedViewController {
                presentedVC.dismiss(animated: true) {
                    rootViewController.present(navController, animated: true, completion: nil)
                }
            } else {
                rootViewController.present(navController, animated: true, completion: nil)
            }
            flutterResult(nil)
        }
        print("\(self.TAG) - showConversationList")
    }

    func startNewConversation(rootViewController: UIViewController?, flutterResult: @escaping FlutterResult) {
        guard let viewController = Zendesk.instance?.messaging?.messagingViewController(
            .showNewConversation(exitAction: .returnToConversationList)
        ) else {
            print("\(self.TAG) - Unable to create Zendesk new conversation view controller")
            flutterResult(FlutterError(
                code: "show_error",
                message: "Unable to create Zendesk new conversation view controller",
                details: nil)
            )
            return
        }
        guard let rootViewController = rootViewController else {
            print("\(self.TAG) - Root view controller is nil")
            flutterResult(FlutterError(
                code: "show_error",
                message: "Root view controller is nil",
                details: nil)
            )
            return
        }

        let navController = UINavigationController(rootViewController: viewController)

        DispatchQueue.main.async {
            if let presentedVC = rootViewController.presentedViewController {
                presentedVC.dismiss(animated: true) {
                    rootViewController.present(navController, animated: true, completion: nil)
                }
            } else {
                rootViewController.present(navController, animated: true, completion: nil)
            }
            flutterResult(nil)
        }
        print("\(self.TAG) - startNewConversation")
    }

    func setConversationTags(tags: [String]) {
        Zendesk.instance?.messaging?.setConversationTags(tags)
        print("\(self.TAG) - setConversationTags: \(tags)")
    }

    func clearConversationTags() {
        Zendesk.instance?.messaging?.clearConversationTags()
        print("\(self.TAG) - clearConversationTags")
    }

    func loginUser(jwt: String, flutterResult: @escaping FlutterResult) {
        Zendesk.instance?.loginUser(with: jwt) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.zendeskPlugin?.isLoggedIn = true
                    flutterResult([
                        "id": user.id,
                        "externalId": user.externalId,
                        "authenticationType": self.getAuthenticationType(user: user)
                    ])
                    print("\(self.TAG) - loginUser success")
                case .failure(let error):
                    print("\(self.TAG) - login failure - \(error.localizedDescription)\n")
                    flutterResult(FlutterError(
                        code: "login_error",
                        message: error.localizedDescription,
                        details: nil)
                    )
                }
            }
        }
    }

    func logoutUser(flutterResult: @escaping FlutterResult) {
        Zendesk.instance?.logoutUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.zendeskPlugin?.isLoggedIn = false
                    flutterResult(nil)
                    print("\(self.TAG) - logoutUser success")
                case .failure(let error):
                    print("\(self.TAG) - logout failure - \(error.localizedDescription)\n")
                    flutterResult(FlutterError(
                        code: "logout_error",
                        message: error.localizedDescription,
                        details: nil)
                    )
                }
            }
        }
    }

    func getCurrentUser(flutterResult: @escaping FlutterResult) {
        if let user = Zendesk.instance?.getCurrentUser() {
            flutterResult([
                "id": user.id,
                "externalId": user.externalId,
                "authenticationType": getAuthenticationType(user: user)
            ])
        } else {
            flutterResult(nil)
        }
    }

    private func getAuthenticationType(user: ZendeskSDK.ZendeskUser) -> String {
        switch user.authenticationType {
        case .jwt:
            return "jwt"
        default:
            return "anonymous"
        }
    }

    func getUnreadMessageCount() -> Int {
        let count = Zendesk.instance?.messaging?.getUnreadMessageCount()
        return count ?? 0
    }

    func getUnreadMessageCountForConversation(conversationId: String) -> Int {
        let count = Zendesk.instance?.messaging?.getUnreadMessageCount(conversationId: conversationId)
        return count ?? 0
    }

    func getConnectionStatus() -> String {
        // Connection status is obtained from events
        return "unknown"
    }

    func listenMessageCountChanged() {
        Zendesk.instance?.addEventObserver(self, { event in
            self.handleZendeskEvent(event: event)
        })
        print("\(self.TAG) - listenMessageCountChanged - Event observer added")
    }

    private func handleZendeskEvent(event: ZendeskSDK.ZendeskEvent) {
        switch event {
        case let .unreadMessageCountChanged(currentUnreadCount):
            // Legacy callback for backwards compatibility
            self.channel.invokeMethod(
                Self.unreadMessages,
                arguments: ["messages_count": currentUnreadCount]
            )
            // New event system
            self.channel.invokeMethod(
                Self.zendeskEvent,
                arguments: [
                    "type": "unreadMessageCountChanged",
                    "timestamp": Int64(Date().timeIntervalSince1970 * 1000),
                    "totalUnreadCount": currentUnreadCount
                ]
            )

        case let .authenticationFailed(error as NSError):
            let isJwtExpired = error.localizedDescription.lowercased().contains("expired")
            self.channel.invokeMethod(
                Self.zendeskEvent,
                arguments: [
                    "type": "authenticationFailed",
                    "timestamp": Int64(Date().timeIntervalSince1970 * 1000),
                    "errorCode": "authentication_failed",
                    "errorMessage": error.localizedDescription,
                    "isJwtExpired": isJwtExpired
                ]
            )

        case let .conversationAdded(conversationId):
            self.channel.invokeMethod(
                Self.zendeskEvent,
                arguments: [
                    "type": "conversationAdded",
                    "timestamp": Int64(Date().timeIntervalSince1970 * 1000),
                    "conversationId": conversationId
                ]
            )

        case let .connectionStatusChanged(connectionStatus):
            let statusString = connectionStatus.stringValue
            self.channel.invokeMethod(
                Self.zendeskEvent,
                arguments: [
                    "type": "connectionStatusChanged",
                    "timestamp": Int64(Date().timeIntervalSince1970 * 1000),
                    "status": statusString
                ]
            )

        case let .sendMessageFailed(error as NSError):
            self.channel.invokeMethod(
                Self.zendeskEvent,
                arguments: [
                    "type": "sendMessageFailed",
                    "timestamp": Int64(Date().timeIntervalSince1970 * 1000),
                    "errorMessage": error.localizedDescription
                ]
            )

        case let .conversationOpened(id, timestamp, conversationId):
            self.channel.invokeMethod(
                Self.zendeskEvent,
                arguments: [
                    "type": "conversationOpened",
                    "id": id.uuidString,
                    "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000),
                    "conversationId": conversationId ?? ""
                ]
            )

        case let .conversationStarted(id, timestamp, conversationId):
            self.channel.invokeMethod(
                Self.zendeskEvent,
                arguments: [
                    "type": "conversationStarted",
                    "id": id.uuidString,
                    "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000),
                    "conversationId": conversationId
                ]
            )

        case let .messagesShown(id, timestamp, conversationId, messages):
            let messagesData = messages.map { message -> [String: Any] in
                return [
                    "id": message.id,
                    "conversationId": conversationId
                ]
            }
            self.channel.invokeMethod(
                Self.zendeskEvent,
                arguments: [
                    "type": "messagesShown",
                    "id": id.uuidString,
                    "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000),
                    "conversationId": conversationId,
                    "messages": messagesData
                ]
            )

        case let .сonversationUnreadCountChanged(id, timestamp, data):
            self.channel.invokeMethod(
                Self.zendeskEvent,
                arguments: [
                    "type": "unreadMessageCountChanged",
                    "id": id.uuidString,
                    "timestamp": Int64(timestamp.timeIntervalSince1970 * 1000),
                    "conversationId": data.conversationId ?? "",
                    "conversationUnreadCount": data.unreadCountInConversation,
                    "totalUnreadCount": data.totalUnreadMessagesCount
                ]
            )

        @unknown default:
            print("\(self.TAG) - Unknown event type")
        }
    }

    func setConversationFields(fields: [String: String]) {
        Zendesk.instance?.messaging?.setConversationFields(fields)
        print("\(self.TAG) - setConversationFields: \(fields)")
    }

    func clearConversationFields() {
        Zendesk.instance?.messaging?.clearConversationFields()
        print("\(self.TAG) - clearConversationFields")
    }

    // ============================================================================
    // Push Notifications
    // ============================================================================

    /// Update the push notification token with Zendesk.
    /// Call this when receiving a new APNs device token.
    func updatePushNotificationToken(_ deviceToken: Data) {
        PushNotifications.updatePushNotificationToken(deviceToken)
        print("\(self.TAG) - updatePushNotificationToken: token updated")
    }

    /// Update the push notification token from a string (FCM token format).
    /// Converts the string to Data before passing to SDK.
    func updatePushNotificationTokenString(_ token: String) {
        // For iOS, we typically receive Data from APNs, but if using FCM,
        // the token comes as a string. We pass it directly to the SDK.
        if let tokenData = token.data(using: .utf8) {
            PushNotifications.updatePushNotificationToken(tokenData)
            print("\(self.TAG) - updatePushNotificationTokenString: token updated")
        } else {
            print("\(self.TAG) - updatePushNotificationTokenString: invalid token format")
        }
    }

    /// Check if a push notification should be displayed by Zendesk.
    /// Returns the responsibility indicating how to handle the notification.
    func shouldBeDisplayed(_ userInfo: [AnyHashable: Any]) -> String {
        let responsibility = PushNotifications.shouldBeDisplayed(userInfo)
        let result: String
        switch responsibility {
        case .messagingShouldDisplay:
            result = "messaging_should_display"
        case .messagingShouldNotDisplay:
            result = "messaging_should_not_display"
        case .notFromMessaging:
            result = "not_from_messaging"
        @unknown default:
            result = "unknown"
        }
        print("\(self.TAG) - shouldBeDisplayed: \(result)")
        return result
    }

    /// Handle and display a push notification.
    /// Returns true if the notification was handled by Zendesk.
    func handleNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        let responsibility = PushNotifications.shouldBeDisplayed(userInfo)
        if responsibility == .messagingShouldDisplay {
            print("\(self.TAG) - handleNotification: Zendesk notification detected")
            return true
        } else {
            print("\(self.TAG) - handleNotification: not a Zendesk notification")
            return false
        }
    }

    /// Handle a notification tap event.
    /// Returns the view controller to display, or nil if not a Zendesk notification.
    func handleNotificationTap(_ userInfo: [AnyHashable: Any], rootViewController: UIViewController?, completion: @escaping (Bool) -> Void) {
        let responsibility = PushNotifications.shouldBeDisplayed(userInfo)
        if responsibility == .messagingShouldDisplay {
            PushNotifications.handleTap(userInfo) { [weak self] viewController in
                guard let self = self else {
                    completion(false)
                    return
                }
                if let vc = viewController, let rootVC = rootViewController {
                    let navController = UINavigationController(rootViewController: vc)
                    DispatchQueue.main.async {
                        if let presentedVC = rootVC.presentedViewController {
                            presentedVC.dismiss(animated: true) {
                                rootVC.present(navController, animated: true, completion: nil)
                            }
                        } else {
                            rootVC.present(navController, animated: true, completion: nil)
                        }
                        completion(true)
                    }
                    print("\(self.TAG) - handleNotificationTap: opened messaging")
                } else {
                    print("\(self.TAG) - handleNotificationTap: viewController is nil (app may have been killed)")
                    completion(false)
                }
            }
        } else {
            print("\(self.TAG) - handleNotificationTap: not a Zendesk notification")
            completion(false)
        }
    }
}
