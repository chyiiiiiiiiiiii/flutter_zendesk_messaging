package com.chyiiiiiiiiiiiiii.zendesk_messaging

import android.app.Activity
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

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
        Log.d(tag, "Plugin attached to engine")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(tag, "Method called: ${call.method}")

        when (call.method) {
            // ====================================================================
            // Initialization & Lifecycle
            // ====================================================================
            "initialize" -> {
                val channelKey = call.argument<String>("channelKey")
                if (channelKey.isNullOrEmpty()) {
                    result.error("invalid_args", "channelKey is required", null)
                    return
                }
                zendeskMessaging.initialize(channelKey, result)
            }

            "isInitialized" -> {
                result.success(isInitialized)
            }

            "invalidate" -> {
                if (!isInitialized) {
                    Log.w(tag, "SDK not initialized")
                    result.error("not_initialized", "Zendesk SDK is not initialized", null)
                    return
                }
                zendeskMessaging.invalidate()
                result.success(null)
            }

            // ====================================================================
            // Messaging UI
            // ====================================================================
            "show" -> {
                if (!isInitialized) {
                    reportNotInitializedError(result)
                    return
                }
                try {
                    zendeskMessaging.show()
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(tag, "Error showing messenger: ${e.message}")
                    result.error("show_error", e.message, null)
                }
            }

            "startNewConversation" -> {
                if (!isInitialized) {
                    reportNotInitializedError(result)
                    return
                }
                try {
                    zendeskMessaging.startNewConversation()
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(tag, "Error starting conversation: ${e.message}")
                    result.error("start_conversation_error", e.message, null)
                }
            }

            // ====================================================================
            // Authentication
            // ====================================================================
            "loginUser" -> {
                if (!isInitialized) {
                    reportNotInitializedError(result)
                    return
                }
                val jwt = call.argument<String>("jwt")
                if (jwt.isNullOrEmpty()) {
                    result.error("invalid_args", "JWT is required", null)
                    return
                }
                zendeskMessaging.loginUser(jwt, result)
            }

            "logoutUser" -> {
                if (!isInitialized) {
                    reportNotInitializedError(result)
                    return
                }
                zendeskMessaging.logoutUser(result)
            }

            "isLoggedIn" -> {
                result.success(isLoggedIn)
            }

            // ====================================================================
            // Conversation Tags
            // ====================================================================
            "setConversationTags" -> {
                if (!isInitialized) {
                    reportNotInitializedError(result)
                    return
                }
                val tags = call.argument<List<String>>("tags")
                if (tags == null) {
                    result.error("invalid_args", "tags is required", null)
                    return
                }
                try {
                    zendeskMessaging.setConversationTags(tags)
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(tag, "Error setting tags: ${e.message}")
                    result.error("set_tags_error", e.message, null)
                }
            }

            "clearConversationTags" -> {
                if (!isInitialized) {
                    reportNotInitializedError(result)
                    return
                }
                try {
                    zendeskMessaging.clearConversationTags()
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(tag, "Error clearing tags: ${e.message}")
                    result.error("clear_tags_error", e.message, null)
                }
            }

            // ====================================================================
            // Conversation Fields
            // ====================================================================
            "setConversationFields" -> {
                if (!isInitialized) {
                    reportNotInitializedError(result)
                    return
                }
                @Suppress("UNCHECKED_CAST")
                val fields = call.argument<Map<String, String>>("fields")
                if (fields == null) {
                    result.error("invalid_args", "fields is required", null)
                    return
                }
                try {
                    zendeskMessaging.setConversationFields(fields)
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(tag, "Error setting fields: ${e.message}")
                    result.error("set_fields_error", e.message, null)
                }
            }

            "clearConversationFields" -> {
                if (!isInitialized) {
                    reportNotInitializedError(result)
                    return
                }
                try {
                    zendeskMessaging.clearConversationFields()
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(tag, "Error clearing fields: ${e.message}")
                    result.error("clear_fields_error", e.message, null)
                }
            }

            // ====================================================================
            // Messages & Notifications
            // ====================================================================
            "getUnreadMessageCount" -> {
                if (!isInitialized) {
                    reportNotInitializedError(result)
                    return
                }
                try {
                    val count = zendeskMessaging.getUnreadMessageCount()
                    result.success(count)
                } catch (e: Exception) {
                    Log.e(tag, "Error getting unread count: ${e.message}")
                    result.error("unread_count_error", e.message, null)
                }
            }

            "updatePushNotificationToken" -> {
                if (!isInitialized) {
                    reportNotInitializedError(result)
                    return
                }
                val token = call.argument<String>("token")
                if (token.isNullOrEmpty()) {
                    result.error("invalid_args", "token is required", null)
                    return
                }
                try {
                    zendeskMessaging.setPushNotificationToken(token)
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(tag, "Error setting push token: ${e.message}")
                    result.error("push_token_error", e.message, null)
                }
            }

            "listenUnreadMessages" -> {
                if (!isInitialized) {
                    reportNotInitializedError(result)
                    return
                }
                try {
                    zendeskMessaging.listenMessageCountChanged()
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(tag, "Error listening to unread messages: ${e.message}")
                    result.error("listen_error", e.message, null)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun reportNotInitializedError(result: MethodChannel.Result) {
        result.error(
            "not_initialized",
            "Zendesk SDK needs to be initialized first",
            null
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        Log.d(tag, "Plugin detached from engine")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d(tag, "Plugin attached to activity")
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