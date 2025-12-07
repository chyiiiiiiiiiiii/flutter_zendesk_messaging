import UIKit
import ZendeskSDK
import ZendeskSDKMessaging
import Flutter
import UserNotifications

public class ZendeskMessaging: NSObject {

    private weak var flutterPlugin: SwiftZendeskMessagingPlugin?
    private let channel: FlutterMethodChannel
    private var isMessagingPresented = false
    private var presentedNavController: UINavigationController?
    private var currentConversationId: String?

    private enum ZendeskViewMode: String { case fullscreen, sheet, pageSheet, formSheet, automatic }

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

    init(flutterPlugin: SwiftZendeskMessagingPlugin, channel: FlutterMethodChannel) {
        self.flutterPlugin = flutterPlugin
        self.channel = channel
        super.init()
    }

    // MARK: - Initialize SDK
    func initialize(channelKey: String, flutterResult: @escaping FlutterResult) {
        Zendesk.initialize(withChannelKey: channelKey,
                           messagingFactory: DefaultMessagingFactory()) { [weak self] result in
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

    // MARK: - Show Chat
    func show(rootViewController: UIViewController?,
              navigationController: UINavigationController? = nil,
              viewMode: String?,
              exitAction: String?,
              useNavigation: Bool = false,
              flutterResult: @escaping FlutterResult) {

        if isMessagingPresented {
            flutterResult(nil)
            return
        }

        let action = parseExitAction(exitAction)

        guard let messagingVC = Zendesk.instance?.messaging?.messagingViewController(
            .showMostRecentConversation(exitAction: action)
        ) else {
            flutterResult(FlutterError(code: "show_error",
                                       message: "Unable to create messaging VC",
                                       details: nil))
            return
        }

        let mode = ZendeskViewMode(rawValue: viewMode ?? "automatic") ?? .automatic

        DispatchQueue.main.async {
            if useNavigation,
               let nav = navigationController
                ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController {
                nav.pushViewController(messagingVC, animated: true)
                self.isMessagingPresented = true
                self.presentedNavController = nav
            } else if let root = rootViewController {
                let nav = UINavigationController(rootViewController: messagingVC)
                nav.modalPresentationStyle = self.presentationStyle(for: mode)
                root.present(nav, animated: true, completion: nil)
                self.isMessagingPresented = true
                self.presentedNavController = nav
                self.setupDismissHandler(for: nav)
            }
            flutterResult(nil)
        }
    }

    // MARK: - Start New Conversation
    func startNewConversation(rootViewController: UIViewController?,
                              viewMode: String?,
                              exitAction: String?,
                              preFilledFields: [String: String]? = nil,
                              tags: [String]? = nil,
                              flutterResult: @escaping FlutterResult) {

        if isMessagingPresented {
            flutterResult(FlutterError(code: "start_new_error",
                                       message: "Messaging UI is already presented",
                                       details: nil))
            return
        }

        guard let messaging = Zendesk.instance?.messaging else {
            flutterResult(FlutterError(code: "start_new_error",
                                       message: "Messaging SDK not initialized",
                                       details: nil))
            return
        }

        if let fields = preFilledFields, !fields.isEmpty {
            messaging.setConversationFields(fields)
        }

        if let tagList = tags, !tagList.isEmpty {
            messaging.setConversationTags(tagList)
        }

        let action = parseExitAction(exitAction)

        let messagingVC = messaging.messagingViewController(
            .showNewConversation(exitAction: action)
        )

        let mode = ZendeskViewMode(rawValue: viewMode ?? "automatic") ?? .automatic

        DispatchQueue.main.async {
            guard let root = rootViewController else {
                flutterResult(FlutterError(code: "start_new_error",
                                           message: "No root view controller",
                                           details: nil))
                return
            }

            let nav = UINavigationController(rootViewController: messagingVC)
            nav.modalPresentationStyle = self.presentationStyle(for: mode)
            root.present(nav, animated: true, completion: nil)
            self.isMessagingPresented = true
            self.presentedNavController = nav
            self.setupDismissHandler(for: nav)

            flutterResult(["status": "new_conversation_started"])
        }
    }

    // MARK: - Helper to Parse Exit Action
    private func parseExitAction(_ exitAction: String?) -> ExitAction {
       guard let action = exitAction?.lowercased() else {
           return .close // Default
       }

       switch action {
       case "close":
           return .close

       case "returntoconversationlist",
            "return_to_conversation_list":
           return .returnToConversationList

       default:
           return .close
       }
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
                    flutterResult(FlutterError(code: "login_error",
                                               message: error.localizedDescription,
                                               details: nil))
                }
            }
        } ?? flutterResult(FlutterError(code: "login_error",
                                        message: "Zendesk SDK not initialized",
                                        details: nil))
    }

    func logoutUser(flutterResult: @escaping FlutterResult) {
        Zendesk.instance?.logoutUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.flutterPlugin?.setLoggedIn(false)
                    flutterResult(nil)
                case .failure(let error):
                    flutterResult(FlutterError(code: "logout_error",
                                               message: error.localizedDescription,
                                               details: nil))
                }
            }
        } ?? flutterResult(FlutterError(code: "logout_error",
                                        message: "Zendesk SDK not initialized",
                                        details: nil))
    }

    // MARK: - Conversation Fields / Tags
    func setConversationTags(_ tags: [String]) {
        Zendesk.instance?.messaging?.setConversationTags(tags)
    }

    func clearConversationTags() {
        Zendesk.instance?.messaging?.clearConversationTags()
    }

    func setConversationFields(_ fields: [String: String]) {
        Zendesk.instance?.messaging?.setConversationFields(fields)
    }

    func clearConversationFields() {
        Zendesk.instance?.messaging?.clearConversationFields()
    }

    // MARK: - Unread Messages
    func getUnreadMessageCount() -> Int {
        return Zendesk.instance?.messaging?.getUnreadMessageCount() ?? 0
    }

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
            default:
                break
            }
            self.channel.invokeMethod("onEvent", arguments: payload)
        }
    }

    // MARK: - Dismiss Handler
    private func setupDismissHandler(for viewController: UIViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            var checkCount = 0
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
                checkCount += 1
                if viewController.view.window == nil {
                    self?.isMessagingPresented = false
                    self?.presentedNavController = nil
                    let payload: [String: Any] = [
                        "type": "messaging_closed",
                        "timestamp": Int(Date().timeIntervalSince1970 * 1000)
                    ]
                    self?.channel.invokeMethod("onEvent", arguments: payload)
                    t.invalidate()
                } else if checkCount > 300 {
                    t.invalidate()
                }
            }
        }
    }

    // MARK: - Invalidate
    func invalidate() {
        if let instance = Zendesk.instance {
            instance.removeEventObserver(self)
        }
        isMessagingPresented = false
        presentedNavController = nil
        currentConversationId = nil
        Zendesk.invalidate()
        flutterPlugin?.setInitialized(false)
        flutterPlugin?.setLoggedIn(false)
    }
}

// MARK: - Push Notification Integration
extension ZendeskMessaging: UNUserNotificationCenterDelegate {

    /// Setup UNUserNotificationCenter delegate
    func setupPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
    }

    /// Called when APNs registration succeeds
    public func didRegisterForRemoteNotifications(deviceToken: Data) {
        PushNotifications.updatePushNotificationToken(deviceToken)
        print("✅ Zendesk device token registered: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    }

    /// Called when APNs registration fails
    public func didFailToRegisterForRemoteNotifications(error: Error) {
        print("❌ Failed to register for APNs: \(error.localizedDescription)")
    }

    /// Handle foreground notifications
    private func handleForegroundNotification(_ userInfo: [AnyHashable: Any],
                                              completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let resp = PushNotifications.shouldBeDisplayed(userInfo)
        switch resp {
        case .messagingShouldDisplay:
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .sound, .badge])
            } else {
                completionHandler([.alert, .sound, .badge])
            }
        case .messagingShouldNotDisplay, .notFromMessaging:
            completionHandler([])
        @unknown default:
            completionHandler([])
        }
    }

    /// Handle notification tap
    private func handleNotificationTap(_ userInfo: [AnyHashable: Any]) {
        let resp = PushNotifications.shouldBeDisplayed(userInfo)
        if resp == .messagingShouldDisplay {
            PushNotifications.handleTap(userInfo, completion: nil)
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        handleForegroundNotification(notification.request.content.userInfo,
                                     completionHandler: completionHandler)
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotificationTap(response.notification.request.content.userInfo)
        completionHandler()
    }
}


// MARK: - MessagingViewControllerWrapper
class MessagingViewControllerWrapper: UIViewController {
    private let messagingViewController: UIViewController
    private let channel: FlutterMethodChannel

    init(messagingViewController: UIViewController, channel: FlutterMethodChannel) {
        self.messagingViewController = messagingViewController
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addChild(messagingViewController)
        messagingViewController.view.frame = view.bounds
        messagingViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(messagingViewController.view)
        messagingViewController.didMove(toParent: self)
    }
}