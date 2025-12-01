import Flutter
import UIKit
import ZendeskSDK
import ZendeskSDKMessaging

public class SwiftZendeskMessagingPlugin: NSObject, FlutterPlugin {
    private let channel: FlutterMethodChannel

    // MARK: - State flags (mirrors Android implementation)
    fileprivate(set) var isInitialized: Bool = false
    fileprivate(set) var isLoggedIn: Bool = false

    private lazy var zendeskMessaging: ZendeskMessaging = {
        ZendeskMessaging(flutterPlugin: self, channel: channel)
    }()

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zendesk_messaging",
                                           binaryMessenger: registrar.messenger())
        let instance = SwiftZendeskMessagingPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - FlutterPlugin
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard
                let args = call.arguments as? [String: Any],
                let channelKey = args["channelKey"] as? String
            else {
                result(FlutterError(code: "invalid_args",
                                    message: "channelKey is required",
                                    details: nil))
                return
            }
            zendeskMessaging.initialize(channelKey: channelKey, flutterResult: result)

        case "show":
            let args = call.arguments as? [String: Any]
            let viewMode = args?["viewMode"] as? String
            let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
            zendeskMessaging.show(
                rootViewController: root,
                navigationController: nil,
                viewMode: viewMode,
                useNavigation: false,
                flutterResult: result
            )

        case "showInNavigation":
            let args = call.arguments as? [String: Any]
            let viewMode = args?["viewMode"] as? String
            let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
            zendeskMessaging.show(
                rootViewController: root,
                navigationController: root as? UINavigationController,
                viewMode: viewMode,
                useNavigation: true,
                flutterResult: result
            )

        case "startNewConversation":
            let args = call.arguments as? [String: Any]
            let viewMode = args?["viewMode"] as? String
            let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
            zendeskMessaging.startNewConversation(
                rootViewController: root,
                viewMode: viewMode,
                flutterResult: result
            )

        case "loginUser":
            guard
                let args = call.arguments as? [String: Any],
                let jwt = args["jwt"] as? String
            else {
                result(FlutterError(code: "invalid_args",
                                    message: "jwt is required",
                                    details: nil))
                return
            }
            zendeskMessaging.loginUser(jwt: jwt, flutterResult: result)

        case "logoutUser":
            zendeskMessaging.logoutUser(flutterResult: result)

        case "setConversationTags":
            if let args = call.arguments as? [String: Any],
               let tags = args["tags"] as? [String] {
                zendeskMessaging.setConversationTags(tags)
                result(nil)
            } else {
                result(FlutterError(code: "invalid_args",
                                    message: "tags is required",
                                    details: nil))
            }

        case "clearConversationTags":
            zendeskMessaging.clearConversationTags()
            result(nil)

        case "setConversationFields":
            if let args = call.arguments as? [String: Any],
               let fields = args["fields"] as? [String: String] {
                zendeskMessaging.setConversationFields(fields)
                result(nil)
            } else {
                result(FlutterError(code: "invalid_args",
                                    message: "fields is required",
                                    details: nil))
            }

        case "clearConversationFields":
            zendeskMessaging.clearConversationFields()
            result(nil)

        case "getUnreadMessageCount":
            let count = zendeskMessaging.getUnreadMessageCount()
            result(count)

        case "isInitialized":
            result(isInitialized)

        case "isLoggedIn":
            result(isLoggedIn)

        case "invalidate":
            zendeskMessaging.invalidate()
            result(nil)

        case "updatePushNotificationToken":
            // iOS-only helper, expects a base64 string token from Dart.
            if let args = call.arguments as? [String: Any],
               let tokenString = args["token"] as? String,
               let tokenData = Data(base64Encoded: tokenString) {
                PushNotifications.updatePushNotificationToken(tokenData)
                result(nil)
            } else {
                result(FlutterError(code: "invalid_args",
                                    message: "token (base64) is required",
                                    details: nil))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Internal helpers used by ZendeskMessaging
    func setInitialized(_ value: Bool) {
        isInitialized = value
    }

    func setLoggedIn(_ value: Bool) {
        isLoggedIn = value
    }
}
