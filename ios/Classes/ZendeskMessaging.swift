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
            if case let .failure(error) = result {
                self.zendeskPlugin?.isInitialize = false
                print("\(self.TAG) - initialize failure - \(error.localizedDescription)\n")
                self.channel?.invokeMethod(ZendeskMessaging.initializeFailure, arguments: ["error": error.localizedDescription])
            } else {
                self.zendeskPlugin?.isInitialize = true
                print("\(self.TAG) - initialize success")
                self.channel?.invokeMethod(ZendeskMessaging.initializeSuccess, arguments: [])
            }
        }
    }

    func show(rootViewController: UIViewController?) {
        guard let messagingViewController = Zendesk.instance?.messaging?.messagingViewController() else { return }
        guard let rootViewController = rootViewController else { return }
        rootViewController.present(messagingViewController, animated: true, completion: nil)
        print("\(self.TAG) - show")
    }
    
    func loginUser(jwt: String) {
        Zendesk.instance?.loginUser(with: jwt) { result in
            switch result {
            case .success(let user):
                self.channel?.invokeMethod(ZendeskMessaging.loginSuccess, arguments: ["id": user.id, "externalId": user.externalId])
                break;
            case .failure(let error):
                print("\(self.TAG) - login failure - \(error.localizedDescription)\n")
                self.channel?.invokeMethod(ZendeskMessaging.loginFailure, arguments: ["error": nil])
                break;
            }
        }
    }
    
    func logoutUser() {
        Zendesk.instance?.logoutUser { result in
            switch result {
            case .success:
                self.channel?.invokeMethod(ZendeskMessaging.logoutSuccess, arguments: [])
                break;
            case .failure(let error):
                print("\(self.TAG) - logout failure - \(error.localizedDescription)\n")
                self.channel?.invokeMethod(ZendeskMessaging.logoutFailure, arguments: ["error": nil])
                break;
            }
        }
    }
}
