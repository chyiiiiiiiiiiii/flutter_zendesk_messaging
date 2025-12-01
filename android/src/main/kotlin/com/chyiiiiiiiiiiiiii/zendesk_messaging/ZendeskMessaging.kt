package com.chyiiiiiiiiiiiiii.zendesk_messaging

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import zendesk.android.Zendesk
import zendesk.android.events.ZendeskEvent
import zendesk.android.events.ZendeskEventListener
import zendesk.android.messaging.MessagingScreen

class ZendeskMessaging(
    private val plugin: ZendeskMessagingPlugin,
    private val channel: MethodChannel
) {

    companion object {
        const val TAG = "[ZendeskMessaging]"
        const val UNREAD_MESSAGES = "unread_messages"
        const val CONVERSATION_EVENT = "conversation_event"
        const val AUTH_FAILED_EVENT = "authentication_failed"
        const val MESSAGING_UI_EVENT = "messaging_ui_event"
    }

    val zendeskEventListener = ZendeskEventListener { event ->
        when (event) {
            // Unread messages
            is ZendeskEvent.UnreadMessageCountChanged -> channel.invokeMethod(
                UNREAD_MESSAGES,
                mapOf("messages_count" to event.currentUnreadCount)
            )

            // Connection status (payload structure may vary between SDK versions; we only forward the event name)
            is ZendeskEvent.ConnectionStatusChanged -> channel.invokeMethod(
                CONVERSATION_EVENT,
                mapOf("event" to "connection_status_changed")
            )

            // Auth failure
            is ZendeskEvent.AuthenticationFailed -> channel.invokeMethod(
                AUTH_FAILED_EVENT,
                mapOf("error" to (event.error?.message ?: "Unknown"))
            )

            // Field validation failed
            is ZendeskEvent.FieldValidationFailed -> channel.invokeMethod(
                CONVERSATION_EVENT,
                mapOf(
                    "event" to "field_validation_failed",
                    "errors" to event.errors.toString()
                )
            )

            // Conversation added
            is ZendeskEvent.ConversationAdded -> channel.invokeMethod(
                CONVERSATION_EVENT,
                mapOf("event" to "conversation_added")
            )

            // Conversation started
            is ZendeskEvent.ConversationStarted -> channel.invokeMethod(
                CONVERSATION_EVENT,
                mapOf("event" to "conversation_started")
            )

            // Conversation opened
            is ZendeskEvent.ConversationOpened -> channel.invokeMethod(
                CONVERSATION_EVENT,
                mapOf("event" to "conversation_opened")
            )

            // Messages shown
            is ZendeskEvent.MessagesShown -> channel.invokeMethod(
                CONVERSATION_EVENT,
                mapOf("event" to "messages_shown")
            )

            // UI events
            is ZendeskEvent.MessagingOpened -> channel.invokeMethod(
                MESSAGING_UI_EVENT,
                mapOf("event" to "messaging_opened")
            )

            is ZendeskEvent.MessagingClosed -> channel.invokeMethod(
                MESSAGING_UI_EVENT,
                mapOf("event" to "messaging_closed")
            )

            else -> {
                // Handle unknown events
            }
        }
    }

    // Initialize SDK
    fun initialize(channelKey: String, result: MethodChannel.Result) {
        val activity = plugin.activity
            ?: return result.error("init_error", "Activity is null", null)

        Zendesk.initialize(
            context = activity,
            channelKey = channelKey,
            successCallback = {
                plugin.isInitialized = true
                Zendesk.instance.addEventListener(zendeskEventListener)
                result.success(null)
            },
            failureCallback = { error ->
                plugin.isInitialized = false
                result.error("initialize_error", error.message, null)
            }
        )
    }

    // Show chat
    fun show(result: MethodChannel.Result) {
        val activity = plugin.activity
            ?: return result.error("show_error", "Activity is null", null)

        if (!plugin.isInitialized) {
            result.error("show_error", "Zendesk SDK not initialized", null)
            return
        }

        try {
            Zendesk.instance.messaging.showMessaging(activity as Context)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to show messaging", e)
            result.error("show_error", e.message ?: "Unknown error", null)
        }
    }

    // Start new conversation
    fun startNewConversation(result: MethodChannel.Result) {
        val activity = plugin.activity
            ?: return result.error("show_error", "Activity is null", null)

        if (!plugin.isInitialized) {
            result.error("start_new_error", "Zendesk SDK not initialized", null)
            return
        }

        try {
            Zendesk.instance.messaging.showMessaging(
                activity as Context,
                MessagingScreen.NewConversation(
                    onExit = MessagingScreen.ExitAction.Close
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Failed to show new conversation", e)
            return result.error("start_new_error", e.message ?: "Unknown error", null)
        }

        // Create synthetic ticket and conversation IDs to mirror iOS behavior
        val ticketId = java.util.UUID.randomUUID().toString()
        val conversationId = java.util.UUID.randomUUID().toString()
        val timestamp = System.currentTimeMillis() / 1000.0

        val ticketMap = mapOf(
            "ticketId" to ticketId,
            "conversationId" to conversationId,
            "status" to "created",
            "timestamp" to timestamp
        )

        result.success(ticketMap)
    }

    // Login / logout
    fun loginUser(jwt: String, result: MethodChannel.Result) {
        if (!plugin.isInitialized) {
            result.error("login_error", "Zendesk SDK not initialized", null)
            return
        }

        Zendesk.instance.loginUser(
            jwt = jwt,
            successCallback = { user ->
                plugin.isLoggedIn = true
                result.success(mapOf(
                    "id" to user.id,
                    "externalId" to (user.externalId ?: "")
                ))
            },
            failureCallback = { error ->
                result.error("login_error", error.message, null)
            }
        )
    }

    fun logoutUser(result: MethodChannel.Result) {
        if (!plugin.isInitialized) {
            result.error("logout_error", "Zendesk SDK not initialized", null)
            return
        }

        Zendesk.instance.logoutUser(
            successCallback = {
                plugin.isLoggedIn = false
                result.success(null)
            },
            failureCallback = { error ->
                result.error("logout_error", error.message, null)
            }
        )
    }

    // Conversation tags / fields
    fun setConversationTags(tags: List<String>) {
        if (!plugin.isInitialized) {
            Log.w(TAG, "setConversationTags called before initialize; ignoring")
            return
        }
        Zendesk.instance.messaging.setConversationTags(tags)
    }

    fun clearConversationTags() {
        if (!plugin.isInitialized) {
            Log.w(TAG, "clearConversationTags called before initialize; ignoring")
            return
        }
        Zendesk.instance.messaging.clearConversationTags()
    }

    fun setConversationFields(fields: Map<String, String>) {
        if (!plugin.isInitialized) {
            Log.w(TAG, "setConversationFields called before initialize; ignoring")
            return
        }
        Zendesk.instance.messaging.setConversationFields(fields)
    }

    fun clearConversationFields() {
        if (!plugin.isInitialized) {
            Log.w(TAG, "clearConversationFields called before initialize; ignoring")
            return
        }
        Zendesk.instance.messaging.clearConversationFields()
    }

    // Unread message count
    fun getUnreadMessageCount(): Int {
        if (!plugin.isInitialized) {
            Log.w(TAG, "getUnreadMessageCount called before initialize; returning 0")
            return 0
        }
        return Zendesk.instance.messaging.getUnreadMessageCount()
    }

    // Push notification token (no-op stub; implement with Zendesk push API when available)
    fun updatePushNotificationToken(token: String) {
        Log.d(TAG, "updatePushNotificationToken called with token=$token (not wired to Zendesk push SDK).")
    }

    // Invalidate
    fun invalidate() {
        Zendesk.instance.removeEventListener(zendeskEventListener)
        Zendesk.invalidate()
        plugin.isInitialized = false
        plugin.isLoggedIn = false
    }
}
//package com.chyiiiiiiiiiiiiii.zendesk_messaging
//
//import android.app.Activity
//import android.util.Log
//import io.flutter.plugin.common.MethodChannel
//import zendesk.android.Zendesk
//import zendesk.android.events.ZendeskEvent
//import zendesk.android.events.ZendeskEventListener
//import zendesk.android.messaging.MessagingScreen
//
//class ZendeskMessaging(
//    private val plugin: ZendeskMessagingPlugin,
//    private val channel: MethodChannel
//) {
//
//    companion object {
//        const val TAG = "[ZendeskMessaging]"
//        const val UNREAD_MESSAGES = "unread_messages"
//        const val CONVERSATION_EVENT = "conversation_event"
//        const val AUTH_FAILED_EVENT = "authentication_failed"
//        const val MESSAGING_UI_EVENT = "messaging_ui_event"
//    }
//
//    val zendeskEventListener = ZendeskEventListener { event ->
//        when (event) {
//            // Unread messages
//            is ZendeskEvent.UnreadMessageCountChanged -> channel.invokeMethod(
//                UNREAD_MESSAGES,
//                mapOf("messages_count" to event.currentUnreadCount)
//            )
//
//            // Connection status (payload structure may vary between SDK versions; we only forward the event name)
//            is ZendeskEvent.ConnectionStatusChanged -> channel.invokeMethod(
//                CONVERSATION_EVENT,
//                mapOf("event" to "connection_status_changed")
//            )
//
//            // Auth failure
//            is ZendeskEvent.AuthenticationFailed -> channel.invokeMethod(
//                AUTH_FAILED_EVENT,
//                mapOf("error" to (event.error?.message ?: "Unknown"))
//            )
//
//            // Field validation failed
//            is ZendeskEvent.FieldValidationFailed -> channel.invokeMethod(
//                CONVERSATION_EVENT,
//                mapOf(
//                    "event" to "field_validation_failed",
//                    "errors" to event.errors.toString()
//                )
//            )
//
//            // Conversation added
//            is ZendeskEvent.ConversationAdded -> channel.invokeMethod(
//                CONVERSATION_EVENT,
//                mapOf("event" to "conversation_added")
//            )
//
//            // Conversation started
//            is ZendeskEvent.ConversationStarted -> channel.invokeMethod(
//                CONVERSATION_EVENT,
//                mapOf("event" to "conversation_started")
//            )
//
//            // Conversation opened
//            is ZendeskEvent.ConversationOpened -> channel.invokeMethod(
//                CONVERSATION_EVENT,
//                mapOf("event" to "conversation_opened")
//            )
//
//            // Messages shown
//            is ZendeskEvent.MessagesShown -> channel.invokeMethod(
//                CONVERSATION_EVENT,
//                mapOf("event" to "messages_shown")
//            )
//
//            // UI events
//            is ZendeskEvent.MessagingOpened -> channel.invokeMethod(
//                MESSAGING_UI_EVENT,
//                mapOf("event" to "messaging_opened")
//            )
//
//            is ZendeskEvent.MessagingClosed -> channel.invokeMethod(
//                MESSAGING_UI_EVENT,
//                mapOf("event" to "messaging_closed")
//            )
//
//            else -> {
//                // Handle unknown events
//            }
//        }
//    }
//
//    // Initialize SDK
//    fun initialize(channelKey: String, result: MethodChannel.Result) {
//        val activity = plugin.activity
//            ?: return result.error("init_error", "Activity is null", null)
//
//        Zendesk.initialize(
//            context = activity,
//            channelKey = channelKey,
//            successCallback = {
//                plugin.isInitialized = true
//                Zendesk.instance.addEventListener(zendeskEventListener)
//                result.success(null)
//            },
//            failureCallback = { error ->
//                plugin.isInitialized = false
//                result.error("initialize_error", error.message, null)
//            }
//        )
//    }
//
//    // Show chat
//    fun show(result: MethodChannel.Result) {
//        val activity = plugin.activity
//            ?: return result.error("show_error", "Activity is null", null)
//
//        if (!plugin.isInitialized) {
//            result.error("show_error", "Zendesk SDK not initialized", null)
//            return
//        }
//
//        Zendesk.instance.messaging.showMessaging(activity)
//        result.success(null)
//    }
//
//    // Start new conversation
//    fun startNewConversation(result: MethodChannel.Result) {
//        val activity = plugin.activity
//            ?: return result.error("show_error", "Activity is null", null)
//
//        if (!plugin.isInitialized) {
//            result.error("start_new_error", "Zendesk SDK not initialized", null)
//            return
//        }
//
//        Zendesk.instance.messaging.showMessaging(
//            activity,
//            MessagingScreen.NewConversation
//        )
//
//        // Create synthetic ticket and conversation IDs to mirror iOS behavior
//        val ticketId = java.util.UUID.randomUUID().toString()
//        val conversationId = java.util.UUID.randomUUID().toString()
//        val timestamp = System.currentTimeMillis() / 1000.0
//
//        val ticketMap = mapOf(
//            "ticketId" to ticketId,
//            "conversationId" to conversationId,
//            "status" to "created",
//            "timestamp" to timestamp
//        )
//
//        result.success(ticketMap)
//    }
//
//    // Login / logout
//    fun loginUser(jwt: String, result: MethodChannel.Result) {
//        if (!plugin.isInitialized) {
//            result.error("login_error", "Zendesk SDK not initialized", null)
//            return
//        }
//
//        Zendesk.instance.loginUser(
//            jwt = jwt,
//            successCallback = { user ->
//                plugin.isLoggedIn = true
//                result.success(mapOf(
//                    "id" to user.id,
//                    "externalId" to (user.externalId ?: "")
//                ))
//            },
//            failureCallback = { error ->
//                result.error("login_error", error.message, null)
//            }
//        )
//    }
//
//    fun logoutUser(result: MethodChannel.Result) {
//        if (!plugin.isInitialized) {
//            result.error("logout_error", "Zendesk SDK not initialized", null)
//            return
//        }
//
//        Zendesk.instance.logoutUser(
//            successCallback = {
//                plugin.isLoggedIn = false
//                result.success(null)
//            },
//            failureCallback = { error ->
//                result.error("logout_error", error.message, null)
//            }
//        )
//    }
//
//    // Conversation tags / fields
//    fun setConversationTags(tags: List<String>) {
//        if (!plugin.isInitialized) {
//            Log.w(TAG, "setConversationTags called before initialize; ignoring")
//            return
//        }
//        Zendesk.instance.messaging.setConversationTags(tags)
//    }
//
//    fun clearConversationTags() {
//        if (!plugin.isInitialized) {
//            Log.w(TAG, "clearConversationTags called before initialize; ignoring")
//            return
//        }
//        Zendesk.instance.messaging.clearConversationTags()
//    }
//
//    fun setConversationFields(fields: Map<String, String>) {
//        if (!plugin.isInitialized) {
//            Log.w(TAG, "setConversationFields called before initialize; ignoring")
//            return
//        }
//        Zendesk.instance.messaging.setConversationFields(fields)
//    }
//
//    fun clearConversationFields() {
//        if (!plugin.isInitialized) {
//            Log.w(TAG, "clearConversationFields called before initialize; ignoring")
//            return
//        }
//        Zendesk.instance.messaging.clearConversationFields()
//    }
//
//    // Unread message count
//    fun getUnreadMessageCount(): Int {
//        if (!plugin.isInitialized) {
//            Log.w(TAG, "getUnreadMessageCount called before initialize; returning 0")
//            return 0
//        }
//        return Zendesk.instance.messaging.getUnreadMessageCount()
//    }
//
//    // Push notification token (no-op stub; implement with Zendesk push API when available)
//    fun updatePushNotificationToken(token: String) {
//        Log.d(TAG, "updatePushNotificationToken called with token=$token (not wired to Zendesk push SDK).")
//    }
//
//    // Invalidate
//    fun invalidate() {
//        Zendesk.instance.removeEventListener(zendeskEventListener)
//        Zendesk.invalidate()
//        plugin.isInitialized = false
//        plugin.isLoggedIn = false
//    }
//}