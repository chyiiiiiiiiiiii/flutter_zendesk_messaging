import Flutter
import UIKit

public class SwiftZendeskMessagingPlugin: NSObject, FlutterPlugin {
    let TAG = "[SwiftZendeskMessagingPlugin]"
    private var channel: FlutterMethodChannel
    var isInitialized = false
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zendesk_messaging", binaryMessenger: registrar.messenger())
        let instance = SwiftZendeskMessagingPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        let arguments = call.arguments as? Dictionary<String, Any>
        let zendeskMessaging = ZendeskMessaging(flutterPlugin: self, channel: channel)

        // chat sdk method channels
        switch(method){
            case "initialize":
                if (isInitialized) {
                    print("\(TAG) - Messaging is already initialize!\n")
                    return
                }
                let channelKey: String = (arguments?["channelKey"] ?? "") as! String
                zendeskMessaging.initialize(channelKey: channelKey)
                break;
            case "show":
                if (!isInitialized) {
                    print("\(TAG) - Messaging needs to be initialized first.\n")
                }
                zendeskMessaging.show(rootViewController: UIApplication.shared.delegate?.window??.rootViewController)
                break
            case "loginUser":
                if (!isInitialized) {
                    print("\(TAG) - Messaging needs to be initialized first.\n")
                }
                let jwt: String = arguments?["jwt"] as! String
                zendeskMessaging.loginUser(jwt: jwt)
                break
            case "logoutUser":
                if (!isInitialized) {
                    print("\(TAG) - Messaging needs to be initialized first.\n")
                }
                zendeskMessaging.logoutUser()
                break
            case "getUnreadMessageCount":
                if (!isInitialized) {
                    print("\(TAG) - Messaging needs to be initialized first.\n")
                }
                result(handleMessageCount())
                break
            
            case "isInitialized":
                result(handleInitializedStatus())
                break
            default:
                break
        }

        result(nil)
    }

    private func handleMessageCount() ->Int{
         let zendeskMessaging = ZendeskMessaging(flutterPlugin: self, channel: channel)

        return zendeskMessaging.getUnreadMessageCount()
    }
    private func handleInitializedStatus() ->Bool{
        return isInitialized
    }
}
