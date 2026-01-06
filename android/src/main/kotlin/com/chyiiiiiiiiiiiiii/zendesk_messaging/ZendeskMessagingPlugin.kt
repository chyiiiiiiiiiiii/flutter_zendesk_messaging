package com.chyiiiiiiiiiiiiii.zendesk_messaging

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** ZendeskMessagingPlugin */
class ZendeskMessagingPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private val tag = "[ZendeskMessagingPlugin]"

    private lateinit var channel: MethodChannel
    private lateinit var zendeskMessaging: ZendeskMessaging

    var activity: Activity? = null
    var isInitialized: Boolean = false
    var isLoggedIn: Boolean = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "zendesk_messaging")
        channel.setMethodCallHandler(this)
        zendeskMessaging = ZendeskMessaging(this, channel)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                val channelKey = call.argument<String>("channelKey")!!
                zendeskMessaging.initialize(channelKey, result)
            }

            "show" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.show()
                result.success(null)
            }

            "showConversation" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                val conversationId = call.argument<String>("conversationId")
                if (conversationId.isNullOrEmpty()) {
                    result.error("invalid_argument", "conversationId is required", null)
                    return
                }
                zendeskMessaging.showConversation(conversationId)
                result.success(null)
            }

            "showConversationList" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.showConversationList()
                result.success(null)
            }

            "startNewConversation" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.startNewConversation()
                result.success(null)
            }

            "isInitialized" -> {
                result.success(isInitialized)
            }

            "isLoggedIn" -> {
                result.success(isLoggedIn)
            }

            "loginUser" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }

                val jwt = call.argument<String>("jwt")
                if (jwt.isNullOrEmpty()) {
                    result.error("login_error", "JWT is empty or null", null)
                    return
                }
                zendeskMessaging.loginUser(jwt, result)
            }

            "logoutUser" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.logoutUser(result)
            }

            "getCurrentUser" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.getCurrentUser(result)
            }

            "getUnreadMessageCount" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                result.success(zendeskMessaging.getUnreadMessageCount())
            }

            "getUnreadMessageCountForConversation" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                val conversationId = call.argument<String>("conversationId")
                if (conversationId.isNullOrEmpty()) {
                    result.error("invalid_argument", "conversationId is required", null)
                    return
                }
                result.success(zendeskMessaging.getUnreadMessageCountForConversation(conversationId))
            }

            "listenUnreadMessages" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }

                try {
                    zendeskMessaging.listenMessageCountChanged()
                    result.success(null)
                } catch (err: Throwable) {
                    println("$tag - ZendeskMessaging::listen unread Messages error")
                    println(err.message)
                    result.error("listen_unread_messages_error", err.message, null)
                }
            }

            "getConnectionStatus" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                result.success(zendeskMessaging.getConnectionStatus())
            }

            "setConversationTags" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }

                try {
                    val tags = call.argument<List<String>>("tags")
                        ?: throw Exception("tags is empty or null")

                    zendeskMessaging.setConversationTags(tags)
                    result.success(null)
                } catch (err: Throwable) {
                    println("$tag - ZendeskMessaging::setConversationTags invalid arguments. {'tags': '<your_tags>'} expected !")
                    println(err.message)
                    result.error("set_conversation_tags_error", err.message, null)
                }
            }

            "clearConversationTags" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.clearConversationTags()
                result.success(null)
            }

            "setConversationFields" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }

                try {
                    val fields = call.argument<Map<String, String>>("fields")
                        ?: throw Exception("fields is empty or null")

                    zendeskMessaging.setConversationFields(fields)
                    result.success(null)
                } catch (err: Throwable) {
                    println("$tag - ZendeskMessaging::setConversationFields invalid arguments. {'fields': Map<String, String>}. expected !")
                    println(err.message)
                    result.error("set_conversation_fields_error", err.message, null)
                }
            }

            "clearConversationFields" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.clearConversationFields()
                result.success(null)
            }

            "invalidate" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK is already on an invalid state")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.invalidate()
                result.success(null)
            }

            // ================================================================
            // Push Notifications
            // ================================================================

            "updatePushNotificationToken" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                try {
                    val token = call.argument<String>("token")
                    if (token.isNullOrEmpty()) {
                        result.error("invalid_argument", "token is required", null)
                        return
                    }
                    zendeskMessaging.updatePushNotificationToken(token)
                    result.success(null)
                } catch (err: Throwable) {
                    println("$tag - updatePushNotificationToken error: ${err.message}")
                    result.error("push_token_error", err.message, null)
                }
            }

            "shouldBeDisplayed" -> {
                try {
                    @Suppress("UNCHECKED_CAST")
                    val messageData = call.argument<Map<String, Any>>("messageData")
                    if (messageData == null) {
                        result.error("invalid_argument", "messageData is required", null)
                        return
                    }
                    // Convert Map<String, Any> to Map<String, String>
                    val stringData = messageData.mapValues { it.value.toString() }
                    val responsibility = zendeskMessaging.shouldBeDisplayed(stringData)
                    result.success(responsibility)
                } catch (err: Throwable) {
                    println("$tag - shouldBeDisplayed error: ${err.message}")
                    result.error("should_be_displayed_error", err.message, null)
                }
            }

            "handleNotification" -> {
                try {
                    @Suppress("UNCHECKED_CAST")
                    val messageData = call.argument<Map<String, Any>>("messageData")
                    if (messageData == null) {
                        result.error("invalid_argument", "messageData is required", null)
                        return
                    }
                    val context = activity ?: run {
                        result.error("no_context", "Activity context is null", null)
                        return
                    }
                    // Convert Map<String, Any> to Map<String, String>
                    val stringData = messageData.mapValues { it.value.toString() }
                    val handled = zendeskMessaging.handleNotification(context, stringData)
                    result.success(handled)
                } catch (err: Throwable) {
                    println("$tag - handleNotification error: ${err.message}")
                    result.error("handle_notification_error", err.message, null)
                }
            }

            "handleNotificationTap" -> {
                if (!isInitialized) {
                    println("$tag - Zendesk SDK needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                try {
                    @Suppress("UNCHECKED_CAST")
                    val messageData = call.argument<Map<String, Any>>("messageData")
                    if (messageData == null) {
                        result.error("invalid_argument", "messageData is required", null)
                        return
                    }
                    val context = activity ?: run {
                        result.error("no_context", "Activity context is null", null)
                        return
                    }
                    // Convert Map<String, Any> to Map<String, String>
                    val stringData = messageData.mapValues { it.value.toString() }
                    zendeskMessaging.handleNotificationTap(context, stringData)
                    result.success(null)
                } catch (err: Throwable) {
                    println("$tag - handleNotificationTap error: ${err.message}")
                    result.error("handle_notification_tap_error", err.message, null)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun reportNotInitializedFlutterError(result: MethodChannel.Result) {
        result.error(
            "not_initialized",
            "Zendesk SDK needs to be initialized first",
            null
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
