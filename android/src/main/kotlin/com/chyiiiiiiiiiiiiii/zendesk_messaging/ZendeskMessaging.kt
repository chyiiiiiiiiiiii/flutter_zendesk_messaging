package com.chyiiiiiiiiiiiiii.zendesk_messaging

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.google.firebase.messaging.RemoteMessage
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
        const val UNREAD_MESSAGES: String = "unread_messages"
        const val ON_EVENT: String = "onEvent"
    }

    private val zendeskEventListener = ZendeskEventListener { event ->
        try {
            handleZendeskEvent(event)
        } catch (e: Exception) {
            Log.e(TAG, "Error handling ZendeskEvent: ${e.message}")
        }
    }

    // =====================================
    // SDK Initialization
    // =====================================
    fun initialize(channelKey: String, result: MethodChannel.Result) {
        try {
            Log.d(TAG, "Initializing with channel key: $channelKey")
            val activity = plugin.activity ?: run {
                result.error("no_activity", "Activity is null", null)
                return
            }

            Zendesk.initialize(
                activity,
                channelKey,
                successCallback = {
                    plugin.isInitialized = true
                    listenMessageCountChanged()
                    Log.d(TAG, "Zendesk initialized successfully")
                    result.success(null)
                },
                failureCallback = { error ->
                    plugin.isInitialized = false
                    Log.e(TAG, "Zendesk initialize failed: ${error.message}")
                    result.error("initialize_error", error.message, null)
                },
                messagingFactory = DefaultMessagingFactory()
            )
        } catch (e: Exception) {
            Log.e(TAG, "Exception in initialize: ${e.message}")
            result.error("initialize_exception", e.message, null)
        }
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
        Log.d(TAG, "Zendesk SDK invalidated")
    }

    // =====================================
    // Messaging UI
    // =====================================
    fun show() {
        try {
            val activity = plugin.activity ?: return
            Zendesk.instance.messaging.showMessaging(activity, Intent.FLAG_ACTIVITY_NEW_TASK)
            Log.d(TAG, "Show messaging UI")
        } catch (e: Exception) {
            Log.e(TAG, "Error showing messaging: ${e.message}")
        }
    }

    fun startNewConversation() {
        try {
            val activity = plugin.activity ?: return
            Zendesk.instance.messaging.showMessaging(activity, Intent.FLAG_ACTIVITY_NEW_TASK)
            Log.d(TAG, "Started new conversation")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting conversation: ${e.message}")
        }
    }

    // =====================================
    // Conversation Tags / Fields
    // =====================================
    fun setConversationTags(tags: List<String>) {
        try {
            Zendesk.instance.messaging.setConversationTags(tags)
            Log.d(TAG, "Set conversation tags: $tags")
        } catch (e: Exception) {
            Log.e(TAG, "Error setting tags: ${e.message}")
        }
    }

    fun clearConversationTags() {
        try {
            Zendesk.instance.messaging.clearConversationTags()
            Log.d(TAG, "Cleared conversation tags")
        } catch (e: Exception) {
            Log.e(TAG, "Error clearing tags: ${e.message}")
        }
    }

    fun setConversationFields(fields: Map<String, String>) {
        try {
            Zendesk.instance.messaging.setConversationFields(fields)
            Log.d(TAG, "Set conversation fields: $fields")
        } catch (e: Exception) {
            Log.e(TAG, "Error setting fields: ${e.message}")
        }
    }

    fun clearConversationFields() {
        try {
            Zendesk.instance.messaging.clearConversationFields()
            Log.d(TAG, "Cleared conversation fields")
        } catch (e: Exception) {
            Log.e(TAG, "Error clearing fields: ${e.message}")
        }
    }

    // =====================================
    // Authentication
    // =====================================
    fun loginUser(jwt: String, result: MethodChannel.Result) {
        try {
            Zendesk.instance.loginUser(jwt, { user ->
                plugin.isLoggedIn = true
                Log.d(TAG, "User logged in: ${user.id}")
                result.success(mapOf("id" to user.id, "externalId" to user.externalId))
            }, { error ->
                Log.e(TAG, "Login failure: ${error.message}")
                result.error("login_error", error.message, null)
            })
        } catch (e: Exception) {
            Log.e(TAG, "Exception in loginUser: ${e.message}")
            result.error("login_exception", e.message, null)
        }
    }

    fun logoutUser(result: MethodChannel.Result) {
        try {
            Zendesk.instance.logoutUser({
                plugin.isLoggedIn = false
                Log.d(TAG, "User logged out")
                result.success(null)
            }, { error ->
                Log.e(TAG, "Logout failure: ${error.message}")
                result.error("logout_error", error.message, null)
            })
            try {
                Zendesk.instance.removeEventListener(zendeskEventListener)
            } catch (e: Exception) {
                Log.w(TAG, "Error removing listener on logout: ${e.message}")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Exception in logoutUser: ${e.message}")
            result.error("logout_exception", e.message, null)
        }
    }

    // =====================================
    // Messages
    // =====================================
    fun getUnreadMessageCount(): Int {
        return try {
            Zendesk.instance.messaging.getUnreadMessageCount()
        } catch (e: Exception) {
            Log.e(TAG, "Error getting unread count: ${e.message}")
            0
        }
    }

    fun listenMessageCountChanged() {
        try {
            Zendesk.instance.addEventListener(zendeskEventListener)
            Log.d(TAG, "Zendesk event listener registered")
        } catch (e: Exception) {
            Log.e(TAG, "Error registering event listener: ${e.message}")
        }
    }

    // =====================================
    // Push Notifications (FCM)
    // =====================================
    fun setPushNotificationToken(token: String) {
        try {
            if (token.isEmpty()) return
            Log.d(TAG, "Received FCM push token: $token")
            // Forward token to your backend if needed
        } catch (e: Exception) {
            Log.e(TAG, "Error setting push token: ${e.message}")
        }
    }

    fun handleFirebaseMessage(remoteMessage: RemoteMessage) {
        try {
            Log.d(TAG, "Received FCM message: ${remoteMessage.data}")
            // Forward to Zendesk server if required
        } catch (e: Exception) {
            Log.e(TAG, "Error handling Firebase message: ${e.message}")
        }
    }

    // =====================================
    // Zendesk Event Handling
    // =====================================
    private fun handleZendeskEvent(event: ZendeskEvent) {
        try {
            when (event) {
                // ====================================================================
                // Unread Messages
                // ====================================================================
                is ZendeskEvent.UnreadMessageCountChanged -> {
                    channel.invokeMethod(
                        UNREAD_MESSAGES,
                        mapOf("messages_count" to event.currentUnreadCount)
                    )
                    channel.invokeMethod(
                        ON_EVENT,
                        mapOf(
                            "type" to "unread_message_count_changed",
                            "currentUnreadCount" to event.currentUnreadCount,
                            "id" to event.id,
                            "timestamp" to event.timestamp
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
                            "error" to event.error.message
                        )
                    )
                }

                // ====================================================================
                // Field Validation
                // ====================================================================
                is ZendeskEvent.FieldValidationFailed -> {
                    val errors = event.errors.mapNotNull { it.message }
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
                            "connectionStatus" to event.connectionStatus.toString()
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
                            "error" to event.cause.message
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
                            "conversationId" to event.conversationId
                        )
                    )
                }

                is ZendeskEvent.ConversationStarted -> {
                    channel.invokeMethod(
                        ON_EVENT,
                        mapOf(
                            "type" to "conversation_started",
                            "id" to event.id,
                            "conversationId" to event.conversationId,
                            "timestamp" to event.timestamp
                        )
                    )
                }

                is ZendeskEvent.ConversationOpened -> {
                    channel.invokeMethod(
                        ON_EVENT,
                        mapOf(
                            "type" to "conversation_opened",
                            "id" to event.id,
                            "conversationId" to event.conversationId,
                            "timestamp" to event.timestamp
                        )
                    )
                }

                is ZendeskEvent.MessagesShown -> {
                    channel.invokeMethod(
                        ON_EVENT,
                        mapOf(
                            "type" to "messages_shown",
                            "id" to event.id,
                            "conversationId" to event.conversationId,
                            "timestamp" to event.timestamp,
                            "messagesCount" to event.messages.size
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
                            "id" to event.id,
                            "timestamp" to event.timestamp
                        )
                    )
                }

                is ZendeskEvent.ProactiveMessageClicked -> {
                    channel.invokeMethod(
                        ON_EVENT,
                        mapOf(
                            "type" to "proactive_message_clicked",
                            "id" to event.id,
                            "timestamp" to event.timestamp
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
                            "id" to event.id,
                            "timestamp" to event.timestamp,
                            "conversationId" to event.data.conversationId
                        )
                    )
                }

                is ZendeskEvent.ConversationServedByAgent -> {
                    channel.invokeMethod(
                        ON_EVENT,
                        mapOf(
                            "type" to "conversation_served_by_agent",
                            "id" to event.id,
                            "timestamp" to event.timestamp,
                            "conversationId" to event.data.conversationId
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
                            "id" to event.id,
                            "timestamp" to event.timestamp,
                            "conversationId" to event.data.conversationId,
                            "url" to event.data.url
                        )
                    )
                }

                is ZendeskEvent.ConversationExtensionDisplayed -> {
                    channel.invokeMethod(
                        ON_EVENT,
                        mapOf(
                            "type" to "conversation_extension_displayed",
                            "id" to event.id,
                            "timestamp" to event.timestamp,
                            "conversationId" to event.data.conversationId,
                            "url" to event.data.url
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
                            "id" to event.id,
                            "timestamp" to event.timestamp
                        )
                    )
                }

                is ZendeskEvent.MessagingClosed -> {
                    channel.invokeMethod(
                        ON_EVENT,
                        mapOf(
                            "type" to "messaging_closed",
                            "id" to event.id,
                            "timestamp" to event.timestamp
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
                            "id" to event.id,
                            "timestamp" to event.timestamp,
                            "conversationId" to event.data.conversationId
                        )
                    )
                }

                is ZendeskEvent.NotificationOpened -> {
                    channel.invokeMethod(
                        ON_EVENT,
                        mapOf(
                            "type" to "notification_opened",
                            "id" to event.id,
                            "timestamp" to event.timestamp,
                            "conversationId" to event.data.conversationId
                        )
                    )
                }

                else -> {
                    Log.w(TAG, "Unknown event: $event")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error emitting ZendeskEvent: ${e.message}")
        }
    }
}
