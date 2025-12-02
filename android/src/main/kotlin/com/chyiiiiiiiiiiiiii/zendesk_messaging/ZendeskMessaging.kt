package com.chyiiiiiiiiiiiiii.zendesk_messaging

import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import zendesk.android.Zendesk
import zendesk.android.events.ZendeskEvent
import zendesk.android.events.ZendeskEventListener
import zendesk.messaging.android.DefaultMessagingFactory

class ZendeskMessaging(
    private val plugin: ZendeskMessagingPlugin,
    private val channel: MethodChannel
) {
    companion object {
        const val TAG = "[ZendeskMessaging]"

        // Method channel callback keys
        const val UNREAD_MESSAGES: String = "unread_messages"
        const val ON_EVENT: String = "onEvent"
    }

    private val zendeskEventListener = ZendeskEventListener { zendeskEvent ->
        when (zendeskEvent) {
            // ====================================================================
            // Unread Messages
            // ====================================================================
            is ZendeskEvent.UnreadMessageCountChanged -> {
                channel.invokeMethod(
                    UNREAD_MESSAGES,
                    mapOf("messages_count" to zendeskEvent.currentUnreadCount)
                )
                // Also emit as generic event
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "unread_message_count_changed",
                        "currentUnreadCount" to zendeskEvent.currentUnreadCount,
                        "id" to zendeskEvent.id,
                        "timestamp" to zendeskEvent.timestamp
                    )
                )
            }

            // ====================================================================
            // Authentication
            // ====================================================================
            is ZendeskEvent.AuthenticationFailed -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "authentication_failed",
                        "error" to zendeskEvent.error.message
                    )
                )
            }

            // ====================================================================
            // Field Validation
            // ====================================================================
            is ZendeskEvent.FieldValidationFailed -> {
                val errors = zendeskEvent.errors.mapNotNull { it.message }
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "field_validation_failed",
                        "errors" to errors
                    )
                )
            }

            // ====================================================================
            // Connection Status
            // ====================================================================
            is ZendeskEvent.ConnectionStatusChanged -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "connection_status_changed",
                        "connectionStatus" to zendeskEvent.connectionStatus.toString()
                    )
                )
            }

            // ====================================================================
            // Messages
            // ====================================================================
            is ZendeskEvent.SendMessageFailed -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "send_message_failed",
                        "error" to zendeskEvent.cause.message
                    )
                )
            }

            // ====================================================================
            // Conversations
            // ====================================================================
            is ZendeskEvent.ConversationAdded -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "conversation_added",
                        "conversationId" to zendeskEvent.conversationId
                    )
                )
            }

            is ZendeskEvent.ConversationStarted -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "conversation_started",
                        "id" to zendeskEvent.id,
                        "conversationId" to zendeskEvent.conversationId,
                        "timestamp" to zendeskEvent.timestamp
                    )
                )
            }

            is ZendeskEvent.ConversationOpened -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "conversation_opened",
                        "id" to zendeskEvent.id,
                        "conversationId" to zendeskEvent.conversationId,
                        "timestamp" to zendeskEvent.timestamp
                    )
                )
            }

            is ZendeskEvent.MessagesShown -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "messages_shown",
                        "id" to zendeskEvent.id,
                        "conversationId" to zendeskEvent.conversationId,
                        "timestamp" to zendeskEvent.timestamp,
                        "messagesCount" to zendeskEvent.messages.size
                    )
                )
            }

            // ====================================================================
            // Proactive Messages
            // ====================================================================
            is ZendeskEvent.ProactiveMessageDisplayed -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "proactive_message_displayed",
                        "id" to zendeskEvent.id,
                        "timestamp" to zendeskEvent.timestamp
                    )
                )
            }

            is ZendeskEvent.ProactiveMessageClicked -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "proactive_message_clicked",
                        "id" to zendeskEvent.id,
                        "timestamp" to zendeskEvent.timestamp
                    )
                )
            }

            // ====================================================================
            // Agent Interactions
            // ====================================================================
            is ZendeskEvent.ConversationWithAgentRequested -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "conversation_with_agent_requested",
                        "id" to zendeskEvent.id,
                        "timestamp" to zendeskEvent.timestamp,
                        "conversationId" to zendeskEvent.data.conversationId
                    )
                )
            }



            is ZendeskEvent.ConversationServedByAgent -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "conversation_served_by_agent",
                        "id" to zendeskEvent.id,
                        "timestamp" to zendeskEvent.timestamp,
                        "conversationId" to zendeskEvent.data.conversationId
                    )
                )
            }

            // ====================================================================
            // Extensions
            // ====================================================================
            is ZendeskEvent.ConversationExtensionOpened -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "conversation_extension_opened",
                        "id" to zendeskEvent.id,
                        "timestamp" to zendeskEvent.timestamp,
                        "conversationId" to zendeskEvent.data.conversationId,
                        "url" to zendeskEvent.data.url
                    )
                )
            }

            is ZendeskEvent.ConversationExtensionDisplayed -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "conversation_extension_displayed",
                        "id" to zendeskEvent.id,
                        "timestamp" to zendeskEvent.timestamp,
                        "conversationId" to zendeskEvent.data.conversationId,
                        "url" to zendeskEvent.data.url
                    )
                )
            }

            // ====================================================================
            // Articles
            // ====================================================================
            is ZendeskEvent.ArticleBrowserClicked -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "article_browser_clicked",
                        "timestamp" to System.currentTimeMillis()
                    )
                )
            }

            is ZendeskEvent.ArticleClicked -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "article_clicked",
                        "timestamp" to System.currentTimeMillis()
                    )
                )
            }

            // ====================================================================
            // Messaging UI
            // ====================================================================
            is ZendeskEvent.MessagingOpened -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "messaging_opened",
                        "id" to zendeskEvent.id,
                        "timestamp" to zendeskEvent.timestamp
                    )
                )
            }

            is ZendeskEvent.MessagingClosed -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "messaging_closed",
                        "id" to zendeskEvent.id,
                        "timestamp" to zendeskEvent.timestamp
                    )
                )
            }

            // ====================================================================
            // Buttons
            // ====================================================================
            is ZendeskEvent.NewConversationButtonClicked -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "new_conversation_button_clicked",
                        "timestamp" to System.currentTimeMillis()
                    )
                )
            }

            is ZendeskEvent.PostbackButtonClicked -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "postback_button_clicked",
                        "timestamp" to System.currentTimeMillis()
                    )
                )
            }

            // ====================================================================
            // Notifications
            // ====================================================================
            is ZendeskEvent.NotificationDisplayed -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "notification_displayed",
                        "id" to zendeskEvent.id,
                        "timestamp" to zendeskEvent.timestamp,
                        "conversationId" to zendeskEvent.data.conversationId
                    )
                )
            }

            is ZendeskEvent.NotificationOpened -> {
                channel.invokeMethod(
                    ON_EVENT,
                    mapOf(
                        "type" to "notification_opened",
                        "id" to zendeskEvent.id,
                        "timestamp" to zendeskEvent.timestamp,
                        "conversationId" to zendeskEvent.data.conversationId
                    )
                )
            }

            else -> {
                Log.w(TAG, "Unknown event: $zendeskEvent")
            }
        }
    }

    fun initialize(channelKey: String, result: MethodChannel.Result) {
        Log.d(TAG, "Initializing with channel key: $channelKey")
        Zendesk.initialize(
            plugin.activity!!,
            channelKey,
            successCallback = { value ->
                plugin.isInitialized = true
                listenMessageCountChanged()
                Log.d(TAG, "Initialize success")
                result.success(null)
            },
            failureCallback = { error ->
                plugin.isInitialized = false
                Log.e(TAG, "Initialize failure: ${error.message}")
                result.error("initialize_error", error.message, null)
            },
            messagingFactory = DefaultMessagingFactory()
        )
    }

    fun invalidate() {
        try {
            Zendesk.instance.removeEventListener(zendeskEventListener)
        } catch (e: Exception) {
            Log.w(TAG, "Error removing event listener: ${e.message}")
        }
        Zendesk.invalidate()
        plugin.isInitialized = false
        plugin.isLoggedIn = false
        Log.d(TAG, "Invalidated")
    }

    fun show() {
        Zendesk.instance.messaging.showMessaging(plugin.activity!!, Intent.FLAG_ACTIVITY_NEW_TASK)
        Log.d(TAG, "Show messaging")
    }

    fun startNewConversation() {
        try {
            Zendesk.instance.messaging.showMessaging(plugin.activity!!, Intent.FLAG_ACTIVITY_NEW_TASK)
            Log.d(TAG, "Started new conversation")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting new conversation: ${e.message}")
        }
    }

    fun getUnreadMessageCount(): Int =
        try {
            Zendesk.instance.messaging.getUnreadMessageCount()
        } catch (error: Throwable) {
            Log.e(TAG, "Error getting unread count: ${error.message}")
            0
        }

    fun setConversationTags(tags: List<String>) {
        Zendesk.instance.messaging.setConversationTags(tags)
        Log.d(TAG, "Set conversation tags: $tags")
    }

    fun clearConversationTags() {
        Zendesk.instance.messaging.clearConversationTags()
        Log.d(TAG, "Cleared conversation tags")
    }

    fun setConversationFields(fields: Map<String, String>) {
        Zendesk.instance.messaging.setConversationFields(fields)
        Log.d(TAG, "Set conversation fields")
    }

    fun clearConversationFields() {
        Zendesk.instance.messaging.clearConversationFields()
        Log.d(TAG, "Cleared conversation fields")
    }

    fun loginUser(jwt: String, result: MethodChannel.Result) {
        Zendesk.instance.loginUser(
            jwt,
            { user ->
                plugin.isLoggedIn = true
                Log.d(TAG, "User logged in: ${user.id}")
                result.success(mapOf("id" to user.id, "externalId" to user.externalId))
            },
            { error ->
                Log.e(TAG, "Login failure: ${error.message}")
                result.error("login_error", error.message, null)
            })
    }

    fun logoutUser(result: MethodChannel.Result) {
        Zendesk.instance.logoutUser(
            successCallback = {
                plugin.isLoggedIn = false
                Log.d(TAG, "User logged out")
                result.success(null)
            },
            failureCallback = { error ->
                Log.e(TAG, "Logout failure: ${error.message}")
                result.error("logout_error", error.message, null)
            }
        )
        try {
            Zendesk.instance.removeEventListener(zendeskEventListener)
        } catch (e: Exception) {
            Log.w(TAG, "Error removing listener on logout: ${e.message}")
        }
    }

    fun setPushNotificationToken(token: String) {
        try {
            // Zendesk SDK may not expose this method directly
            // It's typically handled through Firebase
            Log.d(TAG, "Push notification token received (handled by Firebase integration)")
        } catch (e: Exception) {
            Log.e(TAG, "Error setting push token: ${e.message}")
        }
    }

    fun listenMessageCountChanged() {
        try {
            Zendesk.instance.addEventListener(zendeskEventListener)
            Log.d(TAG, "Event listener registered")
        } catch (e: Exception) {
            Log.e(TAG, "Error registering event listener: ${e.message}")
        }
    }
}