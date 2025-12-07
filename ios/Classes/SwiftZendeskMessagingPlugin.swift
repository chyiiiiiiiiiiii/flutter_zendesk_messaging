import Flutter
import UIKit
import ZendeskSDK
import ZendeskSDKMessaging
import UserNotifications

public class SwiftZendeskMessagingPlugin: NSObject, FlutterPlugin {
    private let channel: FlutterMethodChannel

    // MARK: - State flags
    fileprivate(set) var isInitialized: Bool = false
    fileprivate(set) var isLoggedIn: Bool = false

    private lazy var zendeskMessaging: ZendeskMessaging = {
        ZendeskMessaging(flutterPlugin: self, channel: channel)
    }()

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
        zendeskMessaging.setupPushNotifications() // Setup APNs delegate forwarding
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zendesk_messaging",
                                           binaryMessenger: registrar.messenger())
        let instance = SwiftZendeskMessagingPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - FlutterPlugin Method Call Handler
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
            let exitAction = args?["exitAction"] as? String
            let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
            zendeskMessaging.show(
                rootViewController: root,
                navigationController: nil,
                viewMode: viewMode,
                exitAction: exitAction,
                useNavigation: false,
                flutterResult: result
            )

        case "showInNavigation":
            let args = call.arguments as? [String: Any]
            let viewMode = args?["viewMode"] as? String
            let exitAction = args?["exitAction"] as? String
            let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
            zendeskMessaging.show(
                rootViewController: root,
                navigationController: root as? UINavigationController,
                viewMode: viewMode,
                exitAction: exitAction,
                useNavigation: true,
                flutterResult: result
            )

        case "startNewConversation":
            let args = call.arguments as? [String: Any]
            let viewMode = args?["viewMode"] as? String
            let exitAction = args?["exitAction"] as? String
            let preFilledFields = args?["preFilledFields"] as? [String: String]
            let tags = args?["tags"] as? [String]
            let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
            zendeskMessaging.startNewConversation(
                rootViewController: root,
                viewMode: viewMode,
                exitAction: exitAction,
                preFilledFields: preFilledFields,
                tags: tags,
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
            result(zendeskMessaging.getUnreadMessageCount())

        case "isInitialized":
            result(isInitialized)

        case "isLoggedIn":
            result(isLoggedIn)

        case "invalidate":
            zendeskMessaging.invalidate()
            result(nil)

        case "updatePushNotificationToken":
            if let args = call.arguments as? [String: Any],
               let tokenString = args["token"] as? String,
               let tokenData = Data(base64Encoded: tokenString) {
                zendeskMessaging.didRegisterForRemoteNotifications(deviceToken: tokenData)
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

    // MARK: - Internal helpers
    func setInitialized(_ value: Bool) { isInitialized = value }
    func setLoggedIn(_ value: Bool) { isLoggedIn = value }
}
