import UIKit
import ZendeskSDK
import ZendeskSDKMessaging
import Flutter

public class ZendeskMessaging: NSObject {

    private weak var flutterPlugin: SwiftZendeskMessagingPlugin?
    private let channel: FlutterMethodChannel
    private var isMessagingPresented = false

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
                    flutterResult(nil)
                case .failure(let error):
                    self?.flutterPlugin?.setInitialized(false)
                    flutterResult(FlutterError(code: "initialize_error",
                                               message: error.localizedDescription,
                                               details: nil))
                }
            }
        }
    }

    // MARK: - Show Chat
    func show(rootViewController: UIViewController?,
              navigationController: UINavigationController? = nil,
              viewMode: String?,
              useNavigation: Bool = false,
              flutterResult: @escaping FlutterResult) {

        if isMessagingPresented {
            flutterResult(nil)
            return
        }

        guard let messagingVC = Zendesk.instance?.messaging?.messagingViewController(.showMostRecentConversation(exitAction: .close)) else {
            flutterResult(FlutterError(code: "show_error",
                                       message: "Unable to create messaging VC",
                                       details: nil))
            return
        }

        let wrappedVC = MessagingViewControllerWrapper(messagingViewController: messagingVC,
                                                       channel: channel)
        let mode = ZendeskViewMode(rawValue: viewMode ?? "automatic") ?? .automatic
        wrappedVC.modalPresentationStyle = presentationStyle(for: mode)

        DispatchQueue.main.async {
            if useNavigation,
               let nav = navigationController
                ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController {
                nav.pushViewController(wrappedVC, animated: true)
                self.isMessagingPresented = true
            } else if let root = rootViewController {
                let nav = UINavigationController(rootViewController: wrappedVC)
                nav.modalPresentationStyle = wrappedVC.modalPresentationStyle
                root.present(nav, animated: true, completion: nil)
                self.isMessagingPresented = true
                self.setupDismissHandler(for: nav)
            }
            flutterResult(nil)
        }
    }

    // MARK: - Start New Conversation
    func startNewConversation(rootViewController: UIViewController?,
                              viewMode: String?,
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

        messaging.clearConversationFields()
        messaging.clearConversationTags()

        let messagingVC = messaging.messagingViewController(.showNewConversation(exitAction: .close))
        let wrappedVC = MessagingViewControllerWrapper(messagingViewController: messagingVC,
                                                       channel: channel)
        let mode = ZendeskViewMode(rawValue: viewMode ?? "automatic") ?? .automatic
        wrappedVC.modalPresentationStyle = presentationStyle(for: mode)

        // Create synthetic ticket and conversation IDs (SDK does not expose these directly)
        let ticketId = UUID().uuidString
        let conversationId = UUID().uuidString
        let timestamp = Date().timeIntervalSince1970

        let ticketMap: [String: Any] = [
            "ticketId": ticketId,
            "conversationId": conversationId,
            "status": "created",
            "timestamp": timestamp
        ]

        DispatchQueue.main.async {
            guard let root = rootViewController else {
                flutterResult(FlutterError(code: "start_new_error",
                                           message: "No root view controller",
                                           details: nil))
                return
            }

            let nav = UINavigationController(rootViewController: wrappedVC)
            nav.modalPresentationStyle = wrappedVC.modalPresentationStyle
            root.present(nav, animated: true, completion: nil)
            self.isMessagingPresented = true
            self.setupDismissHandler(for: nav)
            flutterResult(ticketMap)
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

            switch event {
            case .conversationStarted(_, _, let conversationId):
                let payload: [String: Any] = [
                    "event": "conversation_started",
                    "conversationId": conversationId
                ]
                self.channel.invokeMethod("conversation_event", arguments: payload)

            case .conversationOpened(_, _, let conversationId):
                let payload: [String: Any] = [
                    "event": "conversation_opened",
                    "conversationId": conversationId ?? ""
                ]
                self.channel.invokeMethod("conversation_event", arguments: payload)

            case .messagesShown(_, _, let conversationId, _):
                self.channel.invokeMethod("messaging_ui_event",
                                          arguments: ["event": "messaging_opened",
                                                      "conversationId": conversationId])

            case .сonversationUnreadCountChanged(_, _, let change):
                self.channel.invokeMethod("unread_messages",
                                          arguments: ["messages_count": change.totalUnreadMessagesCount])

            case .unreadMessageCountChanged(let currentUnreadCount):
                self.channel.invokeMethod("unread_messages",
                                          arguments: ["messages_count": currentUnreadCount])

            case .authenticationFailed(let error):
                self.channel.invokeMethod("authentication_failed",
                                          arguments: ["error": error.localizedDescription])

            case .conversationAdded(let conversationId):
                self.channel.invokeMethod("conversation_event",
                                          arguments: ["event": "conversation_added",
                                                      "conversationId": conversationId])

            case .connectionStatusChanged(let status):
                self.channel.invokeMethod("conversation_event",
                                          arguments: ["event": "connection_status_changed",
                                                      "status": status.stringValue])

            case .sendMessageFailed(let error):
                self.channel.invokeMethod("conversation_event",
                                          arguments: ["event": "send_message_failed",
                                                      "error": error.localizedDescription])
            }
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
                    self?.channel.invokeMethod("messaging_ui_event", arguments: ["event": "messaging_closed", "dismissType": "user_dismissed"])
                    t.invalidate()
                } else if checkCount > 300 {
                    t.invalidate()
                }
            }
        }
    }
}

extension ZendeskMessaging {
    func invalidate() {
        if let instance = Zendesk.instance {
            instance.removeEventObserver(self)
        }
        isMessagingPresented = false
        Zendesk.invalidate()
        flutterPlugin?.setInitialized(false)
        flutterPlugin?.setLoggedIn(false)
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
