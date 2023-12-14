import UIKit
import ZendeskSDKMessaging
import ZendeskSDK

public class ZendeskMessaging: NSObject {
    private static var initializeSuccess: String = "initialize_success"
    private static var initializeFailure: String = "initialize_failure"
    private static var loginSuccess: String = "login_success"
    private static var loginFailure: String = "login_failure"
    private static var logoutSuccess: String = "logout_success"
    private static var logoutFailure: String = "logout_failure"
    
    let TAG = "[ZendeskMessaging]"
    
    private var zendeskPlugin: SwiftZendeskMessagingPlugin? = nil
    private var channel: FlutterMethodChannel? = nil

    init(flutterPlugin: SwiftZendeskMessagingPlugin, channel: FlutterMethodChannel) {
        self.zendeskPlugin = flutterPlugin
        self.channel = channel
    }
    
    func initialize(channelKey: String) {
        print("\(self.TAG) - Channel Key - \(channelKey)\n")
        Zendesk.initialize(withChannelKey: channelKey, messagingFactory: DefaultMessagingFactory()) { result in
            DispatchQueue.main.async {
                if case let .failure(error) = result {
                    self.zendeskPlugin?.isInitialized = false
                    print("\(self.TAG) - initialize failure - \(error.localizedDescription)\n")
                    self.channel?.invokeMethod(ZendeskMessaging.initializeFailure, arguments: ["error": error.localizedDescription])
                } else {
                    self.zendeskPlugin?.isInitialized = true
                    print("\(self.TAG) - initialize success")
                    self.channel?.invokeMethod(ZendeskMessaging.initializeSuccess, arguments: [:])
                }
            }
        }
    }

    func invalidate() {
        Zendesk.invalidate()
       self.zendeskPlugin?.isInitialized = false
       print("\(self.TAG) - invalidate")
    }
    
    func show(rootViewController: UIViewController?) {
        guard let messagingViewController = Zendesk.instance?.messaging?.messagingViewController() as? UIViewController else {
            print("\(self.TAG) - Unable to create Zendesk messaging view controller")
            return
        }
        guard let rootViewController = rootViewController else {
            print("\(self.TAG) - Root view controller is nil")
            return
        }

        // Check if rootViewController is already presenting another view controller
        if let presentedVC = rootViewController.presentedViewController {
            // Check if the presentedVC is the same instance as messagingViewController
            if presentedVC === messagingViewController {
                // If the same instance, do nothing or update it as necessary
                print("\(self.TAG) - Zendesk messaging view controller is already presented")
            } else {
                // Dismiss current and present new, or just present new
                presentedVC.dismiss(animated: true) {
                    rootViewController.present(messagingViewController, animated: true, completion: nil)
                }
            }
        } else {
            // No view controller is being presented, present the new one
            rootViewController.present(messagingViewController, animated: true, completion: nil)
        }

        print("\(self.TAG) - show")
    }

    func setConversationTags(tags: [String]) {
        Zendesk.instance?.messaging?.setConversationTags(tags)
    }

    func clearConversationTags() {
        Zendesk.instance?.messaging?.clearConversationTags()
    }
    
    func loginUser(jwt: String) {
        Zendesk.instance?.loginUser(with: jwt) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.zendeskPlugin?.isLoggedIn = true
                    self.channel?.invokeMethod(ZendeskMessaging.loginSuccess, arguments: ["id": user.id, "externalId": user.externalId])
                    break
                case .failure(let error):
                    print("\(self.TAG) - login failure - \(error.localizedDescription)\n")
                    self.channel?.invokeMethod(ZendeskMessaging.loginFailure, arguments: ["error": nil])
                    break
                }
            }
        }
    }
    
    func logoutUser() {
        Zendesk.instance?.logoutUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.zendeskPlugin?.isLoggedIn = false
                    self.channel?.invokeMethod(ZendeskMessaging.logoutSuccess, arguments: [])
                    break
                case .failure(let error):
                    print("\(self.TAG) - logout failure - \(error.localizedDescription)\n")
                    self.channel?.invokeMethod(ZendeskMessaging.logoutFailure, arguments: ["error": nil])
                    break
                }
            }
        }
    }
    
    func getUnreadMessageCount() -> Int {
        let count = Zendesk.instance?.messaging?.getUnreadMessageCount()
        return count ?? 0
    }

    func setConversationFields(fields: [String: String]) {
        Zendesk.instance?.messaging?.setConversationFields(fields)
    }

    func clearConversationFields() {
        Zendesk.instance?.messaging?.clearConversationFields()
    }
}
