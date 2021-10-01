import Flutter
import UIKit

public class SwiftZendeskMessagingPlugin: NSObject, FlutterPlugin {
    
  let TAG = "[SwiftZendeskMessagingPlugin]"

  private var channel: FlutterMethodChannel
    
  var isInitialize = false

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
        //
        let zendeskMessaging = ZendeskMessaging(flutterPlugin: self, channel: channel)
        //
        switch(method){
        // chat sdk method channels
        case "initialize":
            if (isInitialize) {
                print("\(TAG) - Messaging is already initialize!\n")
                return
            }
            let channelKey: String = (arguments?["channelKey"] ?? "") as! String
            zendeskMessaging.initialize(channelKey: channelKey)
            break;
        case "show":
            if (!isInitialize) {
                print("\(TAG) - Messaging needs to initialize first.\n")
            }
            zendeskMessaging.show(rootViewController: UIApplication.shared.delegate?.window??.rootViewController)
            break
        default:
            break
        }
        result(nil)
  }
}
