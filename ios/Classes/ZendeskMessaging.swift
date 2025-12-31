import UIKit
import ZendeskSDK
import ZendeskSDKMessaging
import Flutter
import UserNotifications

public class ZendeskMessaging: NSObject {

    // MARK: - Properties
    private weak var flutterPlugin: SwiftZendeskMessagingPlugin?
    private let channel: FlutterMethodChannel
    private var isMessagingPresented = false
    private var presentedNavController: UINavigationController?
    private var currentConversationId: String?

    private enum ZendeskViewMode: String { case fullscreen, sheet, pageSheet, formSheet, automatic }

    // MARK: - Init
    init(flutterPlugin: SwiftZendeskMessagingPlugin, channel: FlutterMethodChannel) {
        self.flutterPlugin = flutterPlugin
        self.channel = channel
        super.init()
    }

    // MARK: - SDK Initialization
    func initialize(channelKey: String, flutterResult: @escaping FlutterResult) {
        Zendesk.initialize(withChannelKey: channelKey, messagingFactory: DefaultMessagingFactory()) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.flutterPlugin?.setInitialized(true)
                    self?.setupEventHandlers()
                    print("✅ Zendesk SDK initialized successfully")
                    flutterResult(nil)
                case .failure(let error):
                    self?.flutterPlugin?.setInitialized(false)
                    print("❌ Zendesk init error: \(error.localizedDescription)")
                    flutterResult(FlutterError(code: "initialize_error",
                                               message: error.localizedDescription,
                                               details: "\(error)"))
                }
            }
        }
    }

    // MARK: - Show / Start Conversation
    public func showConversation(
        newConversation: Bool = false,
        rootViewController: UIViewController?,
        navigationController: UINavigationController? = nil,
        viewMode: String?,
        exitAction: String?,
        preFilledFields: [String: String]? = nil,
        tags: [String]? = nil,
        useNavigation: Bool = false,
        flutterResult: @escaping FlutterResult
    ) {
        // Prevent multiple presentations
        if isMessagingPresented {
            flutterResult(FlutterError(code: "show_error",
                                       message: "Messaging UI already presented",
                                       details: nil))
            return
        }

        guard let messaging = Zendesk.instance?.messaging else {
            flutterResult(FlutterError(code: "show_error",
                                       message: "Messaging SDK not initialized",
                                       details: nil))
            return
        }

        // Set pre-filled fields and tags
        if let fields = preFilledFields { messaging.setConversationFields(fields) }
        if let tagList = tags { messaging.setConversationTags(tagList) }

        let action = parseExitAction(exitAction)
        let messagingVC = newConversation
            ? messaging.messagingViewController(.showNewConversation(exitAction: action))
            : messaging.messagingViewController(.showMostRecentConversation(exitAction: action))

        let mode = ZendeskViewMode(rawValue: viewMode ?? "automatic") ?? .automatic
        presentMessaging(messagingVC: messagingVC,
                         rootViewController: rootViewController,
                         navigationController: navigationController,
                         useNavigation: useNavigation,
                         viewMode: mode,
                         flutterResult: flutterResult)
    }

    // MARK: - Presentation Helper
    private func presentMessaging(
        messagingVC: UIViewController,
        rootViewController: UIViewController?,
        navigationController: UINavigationController?,
        useNavigation: Bool,
        viewMode: ZendeskViewMode,
        flutterResult: @escaping FlutterResult
    ) {
        DispatchQueue.main.async {
            let nav: UINavigationController

            if useNavigation, let navController = navigationController ?? Self.getKeyWindowRootNavigationController() {
                navController.pushViewController(messagingVC, animated: true)
                self.isMessagingPresented = true
                self.presentedNavController = navController
            } else if let root = rootViewController {
                nav = UINavigationController(rootViewController: messagingVC)
                nav.modalPresentationStyle = self.presentationStyle(for: viewMode)
                root.present(nav, animated: true, completion: nil)
                self.isMessagingPresented = true
                self.presentedNavController = nav
                self.setupDismissHandler(for: nav)
            } else {
                flutterResult(FlutterError(code: "presentation_error",
                                           message: "No root view controller available",
                                           details: nil))
                return
            }

            flutterResult(["status": "conversation_presented"])
        }
    }

    private func presentationStyle(for mode: ZendeskViewMode) -> UIModalPresentationStyle {
        switch mode {
        case .fullscreen: return .fullScreen
        case .sheet:
            if #available(iOS 15.0, *) { return .pageSheet }
            return .formSheet
        case .pageSheet: return .pageSheet
        case .formSheet: return .formSheet
        case .automatic: return .automatic
        }
    }

    private static func getKeyWindowRootNavigationController() -> UINavigationController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        for scene in scenes {
            if let nav = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController {
                return nav
            }
        }
        return nil
    }

    private func parseExitAction(_ exitAction: String?) -> ExitAction {
        guard let action = exitAction?.lowercased() else { return .close }
        switch action {
        case "close": return .close
        default: return .close
        }
    }

    // MARK: - Dismiss Handler
    private func setupDismissHandler(for navController: UINavigationController) {
        navController.presentationController?.delegate = self
    }

    // MARK: - Login / Logout
    func loginUser(jwt: String, flutterResult: @escaping FlutterResult) {
        Zendesk.instance?.loginUser(with: jwt) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.flutterPlugin?.setLoggedIn(true)
                    flutterResult(["id": "", "externalId": ""])
                case .failure(let error):
                    flutterResult(FlutterError(code: "login_error", message: error.localizedDescription, details: nil))
                }
            }
        } ?? flutterResult(FlutterError(code: "login_error", message: "Zendesk SDK not initialized", details: nil))
    }

    func logoutUser(flutterResult: @escaping FlutterResult) {
        Zendesk.instance?.logoutUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.flutterPlugin?.setLoggedIn(false)
                    flutterResult(nil)
                case .failure(let error):
                    flutterResult(FlutterError(code: "logout_error", message: error.localizedDescription, details: nil))
                }
            }
        } ?? flutterResult(FlutterError(code: "logout_error", message: "Zendesk SDK not initialized", details: nil))
    }

    // MARK: - Conversation Fields / Tags
    func setConversationTags(_ tags: [String]) { Zendesk.instance?.messaging?.setConversationTags(tags) }
    func clearConversationTags() { Zendesk.instance?.messaging?.clearConversationTags() }
    func setConversationFields(_ fields: [String: String]) { Zendesk.instance?.messaging?.setConversationFields(fields) }
    func clearConversationFields() { Zendesk.instance?.messaging?.clearConversationFields() }

    // MARK: - Unread Messages
    func getUnreadMessageCount() -> Int { Zendesk.instance?.messaging?.getUnreadMessageCount() ?? 0 }

    // MARK: - Event Handlers
    private func setupEventHandlers() {
        guard let zendesk = Zendesk.instance else { return }
        zendesk.addEventObserver(self) { [weak self] event in
            guard let self = self else { return }
            var payload: [String: Any] = ["timestamp": Int(Date().timeIntervalSince1970 * 1000)]
            switch event {
            case .conversationStarted(_, _, let conversationId):
                self.currentConversationId = conversationId
                payload["type"] = "conversation_started"
                payload["conversationId"] = conversationId
            case .conversationOpened(_, _, let conversationId):
                self.currentConversationId = conversationId
                payload["type"] = "conversation_opened"
                payload["conversationId"] = conversationId ?? ""
            case .messagesShown(_, _, let conversationId, _):
                payload["type"] = "messaging_opened"
                payload["conversationId"] = conversationId
            case .unreadMessageCountChanged(let count):
                payload["type"] = "unread_message_count_changed"
                payload["currentUnreadCount"] = count
            case .authenticationFailed(let error):
                payload["type"] = "authentication_failed"
                payload["error"] = error.localizedDescription
            case .conversationAdded(let conversationId):
                payload["type"] = "conversation_added"
                payload["conversationId"] = conversationId
            case .connectionStatusChanged(let status):
                payload["type"] = "connection_status_changed"
                payload["connectionStatus"] = status.stringValue
            case .sendMessageFailed(let error):
                payload["type"] = "send_message_failed"
                payload["error"] = error.localizedDescription
            default: break
            }
            self.channel.invokeMethod("onEvent", arguments: payload)
        }
    }

    // MARK: - Invalidate
    func invalidate() {
        if let instance = Zendesk.instance { instance.removeEventObserver(self) }
        isMessagingPresented = false
        presentedNavController = nil
        currentConversationId = nil
        Zendesk.invalidate()
        flutterPlugin?.setInitialized(false)
        flutterPlugin?.setLoggedIn(false)
    }

    // MARK: - Push Notifications (Public)
    public func setupPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
    }

    public func didRegisterForRemoteNotifications(deviceToken: Data) {
        PushNotifications.updatePushNotificationToken(deviceToken)
        print("✅ Zendesk device token registered: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    }

    public func didFailToRegisterForRemoteNotifications(error: Error) {
        print("❌ Failed to register for APNs: \(error.localizedDescription)")
    }

    // MARK: - Backward Compatibility Wrappers
    public func show(rootViewController: UIViewController?,
                     navigationController: UINavigationController? = nil,
                     viewMode: String?,
                     exitAction: String?,
                     useNavigation: Bool = false,
                     flutterResult: @escaping FlutterResult) {
        showConversation(newConversation: false,
                         rootViewController: rootViewController,
                         navigationController: navigationController,
                         viewMode: viewMode,
                         exitAction: exitAction,
                         useNavigation: useNavigation,
                         flutterResult: flutterResult)
    }

    public func startNewConversation(rootViewController: UIViewController?,
                                     navigationController: UINavigationController? = nil,
                                     viewMode: String?,
                                     exitAction: String?,
                                     preFilledFields: [String: String]? = nil,
                                     tags: [String]? = nil,
                                     flutterResult: @escaping FlutterResult) {
        showConversation(newConversation: true,
                         rootViewController: rootViewController,
                         navigationController: navigationController,
                         viewMode: viewMode,
                         exitAction: exitAction,
                         preFilledFields: preFilledFields,
                         tags: tags,
                         flutterResult: flutterResult)
    }
}

// MARK: - Dismiss Delegate
extension ZendeskMessaging: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        isMessagingPresented = false
        presentedNavController = nil
        let payload: [String: Any] = [
            "type": "messaging_closed",
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ]
        channel.invokeMethod("onEvent", arguments: payload)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension ZendeskMessaging: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let resp = PushNotifications.shouldBeDisplayed(notification.request.content.userInfo)
        switch resp {
        case .messagingShouldDisplay:
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .sound, .badge])
            } else {
                completionHandler([.alert, .sound, .badge])
            }
        default:
            completionHandler([])
        }
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        if PushNotifications.shouldBeDisplayed(response.notification.request.content.userInfo) == .messagingShouldDisplay {
            PushNotifications.handleTap(response.notification.request.content.userInfo, completion: nil)
        }
        completionHandler()
    }
}
