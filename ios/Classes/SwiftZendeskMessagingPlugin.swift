import Flutter
import UIKit

public class SwiftZendeskMessagingPlugin: NSObject, FlutterPlugin {
    let TAG = "[SwiftZendeskMessagingPlugin]"
    private var channel: FlutterMethodChannel
    private var zendeskMessaging: ZendeskMessaging?
    var isInitialized = false
    var isLoggedIn = false

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
        self.zendeskMessaging = ZendeskMessaging(flutterPlugin: self, channel: channel)
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zendesk_messaging", binaryMessenger: registrar.messenger())
        let instance = SwiftZendeskMessagingPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            self.processMethodCall(call, result: result)
        }
    }

    private func processMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        let arguments = call.arguments as? Dictionary<String, Any>

        switch method {
        case "initialize":
            let channelKey: String = (arguments?["channelKey"] ?? "") as! String
            zendeskMessaging?.initialize(channelKey: channelKey, flutterResult: result)

        case "show":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            zendeskMessaging?.show(rootViewController: UIApplication.shared.delegate?.window??.rootViewController, flutterResult: result)

        case "showConversation":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            guard let conversationId = arguments?["conversationId"] as? String, !conversationId.isEmpty else {
                result(FlutterError(code: "invalid_argument", message: "conversationId is required", details: nil))
                return
            }
            zendeskMessaging?.showConversation(conversationId: conversationId, rootViewController: UIApplication.shared.delegate?.window??.rootViewController, flutterResult: result)

        case "showConversationList":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            zendeskMessaging?.showConversationList(rootViewController: UIApplication.shared.delegate?.window??.rootViewController, flutterResult: result)

        case "startNewConversation":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            zendeskMessaging?.startNewConversation(rootViewController: UIApplication.shared.delegate?.window??.rootViewController, flutterResult: result)

        case "loginUser":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            let jwt: String = arguments?["jwt"] as? String ?? ""
            zendeskMessaging?.loginUser(jwt: jwt, flutterResult: result)

        case "logoutUser":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            zendeskMessaging?.logoutUser(flutterResult: result)

        case "getCurrentUser":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            zendeskMessaging?.getCurrentUser(flutterResult: result)

        case "getUnreadMessageCount":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            result(handleMessageCount())

        case "getUnreadMessageCountForConversation":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            guard let conversationId = arguments?["conversationId"] as? String, !conversationId.isEmpty else {
                result(FlutterError(code: "invalid_argument", message: "conversationId is required", details: nil))
                return
            }
            result(zendeskMessaging?.getUnreadMessageCountForConversation(conversationId: conversationId) ?? 0)

        case "listenUnreadMessages":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            zendeskMessaging?.listenMessageCountChanged()
            result(nil)

        case "getConnectionStatus":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            result(zendeskMessaging?.getConnectionStatus() ?? "unknown")

        case "isInitialized":
            result(handleInitializedStatus())

        case "isLoggedIn":
            result(handleLoggedInStatus())

        case "setConversationTags":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            let tags: [String] = arguments?["tags"] as? [String] ?? []
            zendeskMessaging?.setConversationTags(tags: tags)
            result(nil)

        case "clearConversationTags":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            zendeskMessaging?.clearConversationTags()
            result(nil)

        case "setConversationFields":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            let fields: [String: String] = arguments?["fields"] as? [String: String] ?? [:]
            zendeskMessaging?.setConversationFields(fields: fields)
            result(nil)

        case "clearConversationFields":
            if !isInitialized {
                print("\(TAG) - Messaging needs to be initialized first.\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            zendeskMessaging?.clearConversationFields()
            result(nil)

        case "invalidate":
            if !isInitialized {
                print("\(TAG) - Messaging is already on an invalid state\n")
                reportNotInitializedFlutterError(result: result)
                return
            }
            zendeskMessaging?.invalidate()
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleMessageCount() -> Int {
        return zendeskMessaging?.getUnreadMessageCount() ?? 0
    }

    private func handleInitializedStatus() -> Bool {
        return isInitialized
    }

    private func handleLoggedInStatus() -> Bool {
        return isLoggedIn
    }

    private func reportNotInitializedFlutterError(result: FlutterResult) {
        result(FlutterError(
            code: "not_initialized",
            message: "Zendesk SDK needs to be initialized first",
            details: nil)
        )
    }
}
