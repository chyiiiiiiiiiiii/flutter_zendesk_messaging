package com.chyiiiiiiiiiiiiii.zendesk_messaging

import ZendeskMessaging
import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** ZendeskMessagingPlugin */
class ZendeskMessagingPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private val tag = "[ZendeskMessagingPlugin]"
    private lateinit var channel: MethodChannel
    var activity: Activity? = null
    var isInitialized: Boolean = false
    var isLoggedIn: Boolean = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val sendData: Any? = call.arguments
        val zendeskMessaging = ZendeskMessaging(this, channel)

        when (call.method) {
            "initialize" -> {
                if (isInitialized) {
                    println("$tag - Messaging is already initialized!")
                    reportAlreadyInitializedFlutterError(result)
                    return
                }
                val channelKey = call.argument<String>("channelKey")!!
                zendeskMessaging.initialize(channelKey)
                result.success(null)
            }

            "show" -> {
                if (!isInitialized) {
                    println("$tag - Messaging needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.show()
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
                    println("$tag - Messaging needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }

                try {
                    val jwt = call.argument<String>("jwt")
                    if (jwt.isNullOrEmpty()) {
                        throw Exception("JWT is empty or null")
                    }
                    zendeskMessaging.loginUser(jwt)
                    result.success(null)
                } catch (err: Throwable) {
                    println("$tag - Messaging::login invalid arguments. {'jwt': '<your_jwt>'} expected !")
                    println(err.message)
                    result.error("login_error", err.message, null)
                }
            }

            "logoutUser" -> {
                if (!isInitialized) {
                    println("$tag - Messaging needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.logoutUser()
                result.success(null)
            }

            "getUnreadMessageCount" -> {
                if (!isInitialized) {
                    println("$tag - Messaging needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                result.success(zendeskMessaging.getUnreadMessageCount())
            }

            "listenUnreadMessages" -> {
                if (!isInitialized) {
                    println("$tag - Messaging needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }

                try {
                    zendeskMessaging.listenMessageCountChanged()
                    result.success(null)
                } catch (err: Throwable) {
                    println("$tag - Messaging::listen unread Messages error")
                    println(err.message)
                    result.error("listen_unread_messages_error", err.message, null)
                }
            }

            "setConversationTags" -> {
                if (!isInitialized) {
                    println("$tag - Messaging needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }

                try {
                    val tags = call.argument<List<String>>("tags")
                        ?: throw Exception("tags is empty or null")

                    zendeskMessaging.setConversationTags(tags)
                    result.success(null)
                } catch (err: Throwable) {
                    println("$tag - Messaging::setConversationTags invalid arguments. {'tags': '<your_tags>'} expected !")
                    println(err.message)
                    result.error("set_conversation_tags_error", err.message, null)
                }
            }

            "clearConversationTags" -> {
                if (!isInitialized) {
                    println("$tag - Messaging needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.clearConversationTags()
                result.success(null)
            }

            "setConversationFields" -> {
                if (!isInitialized) {
                    println("$tag - Messaging needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }

                try {
                    val fields = call.argument<Map<String, String>>("fields")
                        ?: throw Exception("fields is empty or null")

                    zendeskMessaging.setConversationFields(fields)
                    result.success(null)
                } catch (err: Throwable) {
                    println("$tag - Messaging::setConversationFields invalid arguments. {'fields': Map<String, String>}. expected !")
                    println(err.message)
                    result.error("set_conversation_fields_error", err.message, null)
                }
            }

            "clearConversationFields" -> {
                if (!isInitialized) {
                    println("$tag - Messaging needs to be initialized first")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.clearConversationFields()
                result.success(null)
            }

            "invalidate" -> {
                if (!isInitialized) {
                    println("$tag - Messaging is already on an invalid state")
                    reportNotInitializedFlutterError(result)
                    return
                }
                zendeskMessaging.invalidate()
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }

        if (sendData != null) {
            result.success(sendData)
        } else {
            result.success(0)
        }
    }

    private fun reportAlreadyInitializedFlutterError(result: MethodChannel.Result) {
        result.error(
            "already_initialized",
            "ZendeskMessaging is already initialized",
            null
        )
    }

    private fun reportNotInitializedFlutterError(result: MethodChannel.Result) {
        result.error(
            "not_initialized",
            "ZendeskMessaging needs to be initialized first",
            null
        )
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "zendesk_messaging")
        channel.setMethodCallHandler(this)
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