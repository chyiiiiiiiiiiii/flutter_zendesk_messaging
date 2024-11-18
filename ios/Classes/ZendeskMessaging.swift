import UIKit
import ZendeskSDKMessaging
import ZendeskSDK

public class ZendeskMessaging: NSObject {
    private static let unreadMessages: String = "unread_messages"
    
    let TAG = "[ZendeskMessaging]"
    
    private weak var zendeskPlugin: SwiftZendeskMessagingPlugin?
    private let channel: FlutterMethodChannel

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
        Zendesk.invalidate()
        self.zendeskPlugin?.isInitialized = false
        print("\(self.TAG) - invalidate")
    }
    
    func show(rootViewController: UIViewController?, flutterResult: @escaping FlutterResult) {
        guard let messagingViewController = Zendesk.instance?.messaging?.messagingViewController() as? UIViewController else {
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

        // Check if rootViewController is already presenting another view controller
        let navController = UINavigationController(rootViewController: messagingViewController)

        // Present the navigation controller
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

    func setConversationTags(tags: [String]) {
        Zendesk.instance?.messaging?.setConversationTags(tags)
    }

    func clearConversationTags() {
        Zendesk.instance?.messaging?.clearConversationTags()
    }
    
    func loginUser(jwt: String, flutterResult: @escaping FlutterResult) {
        Zendesk.instance?.loginUser(with: jwt) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.zendeskPlugin?.isLoggedIn = true
                    flutterResult([
                        "id": user.id,
                        "externalId": user.externalId
                    ])
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
    
    func getUnreadMessageCount() -> Int {
        let count = Zendesk.instance?.messaging?.getUnreadMessageCount()
        return count ?? 0
    }
    
    func listenMessageCountChanged() {
        Zendesk.instance?.addEventObserver(self, { event in
            switch event {
            case let .unreadMessageCountChanged(currentUnreadCount):
                self.channel.invokeMethod(
                    Self.unreadMessages,
                    arguments: ["messages_count": currentUnreadCount]
                )
            default:
                break
            }
        })
    }

    func setConversationFields(fields: [String: String]) {
        Zendesk.instance?.messaging?.setConversationFields(fields)
    }

    func clearConversationFields() {
        Zendesk.instance?.messaging?.clearConversationFields()
    }
}
