import Flutter
import UIKit

public class SwiftZendeskMessagingPlugin: NSObject, FlutterPlugin {
    
  private var channel: FlutterMethodChannel

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
        let _ = call.arguments as? Dictionary<String, Any>
        //
        let zendeskMessaging = ZendeskMessaging()
        //
        switch(method){
        // chat sdk method channels
        case "initialize":
            zendeskMessaging.initialize()
            break;
        case "show":
            zendeskMessaging.show(rootViewController: UIApplication.shared.delegate?.window??.rootViewController)
            break
        default:
            break
        }
        result(nil)
  }
}
