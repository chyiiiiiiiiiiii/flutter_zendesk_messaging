package com.chyiiiiiiiiiiiiii.zendesk_messaging

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class ZendeskMessagingPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var zendeskMessaging: ZendeskMessaging

    var activity: Activity? = null
    var isInitialized = false
    var isLoggedIn = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "zendesk_messaging")
        channel.setMethodCallHandler(this)
        zendeskMessaging = ZendeskMessaging(this, channel)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                val channelKey = call.argument<String>("channelKey")
                if (channelKey != null) {
                    zendeskMessaging.initialize(channelKey, result)
                } else {
                    result.error("invalid_args", "channelKey is required", null)
                }
            }

            "show" -> zendeskMessaging.show(result)

            "loginUser" -> {
                val jwt = call.argument<String>("jwt")
                if (jwt != null) {
                    zendeskMessaging.loginUser(jwt, result)
                } else {
                    result.error("invalid_args", "jwt is required", null)
                }
            }

            "logoutUser" -> zendeskMessaging.logoutUser(result)

            "setConversationTags" -> {
                val tags = call.argument<List<String>>("tags")
                if (tags != null) {
                    zendeskMessaging.setConversationTags(tags)
                    result.success(null)
                } else {
                    result.error("invalid_args", "tags is required", null)
                }
            }

            "clearConversationTags" -> {
                zendeskMessaging.clearConversationTags()
                result.success(null)
            }

            "setConversationFields" -> {
                val fields = call.argument<Map<String, String>>("fields")
                if (fields != null) {
                    zendeskMessaging.setConversationFields(fields)
                    result.success(null)
                } else {
                    result.error("invalid_args", "fields is required", null)
                }
            }

            "clearConversationFields" -> {
                zendeskMessaging.clearConversationFields()
                result.success(null)
            }

            "getUnreadMessageCount" -> {
                val count = zendeskMessaging.getUnreadMessageCount()
                result.success(count)
            }

            "isInitialized" -> result.success(isInitialized)

            "isLoggedIn" -> result.success(isLoggedIn)

            "invalidate" -> {
                zendeskMessaging.invalidate()
                result.success(null)
            }

            "startNewConversation" -> zendeskMessaging.startNewConversation(result)

            "updatePushNotificationToken" -> {
                val token = call.argument<String>("token")
                if (token != null) {
                    zendeskMessaging.updatePushNotificationToken(token)
                    result.success(null)
                } else {
                    result.error("invalid_args", "token is required", null)
                }
            }

            else -> result.notImplemented()
        }
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