import UIKit
import ZendeskSDKMessaging
import ZendeskSDKLogger

public class ZendeskMessaging: NSObject {
    
    let TAG = "[ZendeskMessaging]"
    
    private var zendeskPlugin: SwiftZendeskMessagingPlugin? = nil
    private var channel: FlutterMethodChannel? = nil

    init(flutterPlugin: SwiftZendeskMessagingPlugin, channel: FlutterMethodChannel) {
        self.zendeskPlugin = flutterPlugin
        self.channel = channel
    }
    
    func initialize(channelKey: String) {
        print("\(self.TAG) - Channel Key - \(channelKey)\n")
        Messaging.initialize(channelKey: channelKey) { result in
            if case let .failure(error) = result {
                self.zendeskPlugin?.isInitialize = false
                print("\(self.TAG) - initialize failure - \(error.errorDescription ?? "")\n")
            } else {
                self.zendeskPlugin?.isInitialize = true
                print("\(self.TAG) - initialize success")
            }
        }
    }

    func show(rootViewController: UIViewController?) {
        guard let messagingViewController = Messaging.instance?.messagingViewController() else { return }
        guard let rootViewController = rootViewController else { return }
        rootViewController.present(messagingViewController, animated: true, completion: nil)
        print("\(self.TAG) - show")
    }
    
}
