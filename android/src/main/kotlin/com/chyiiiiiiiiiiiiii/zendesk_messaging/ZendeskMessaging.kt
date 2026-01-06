package com.chyiiiiiiiiiiiiii.zendesk_messaging

import android.content.Context
import io.flutter.plugin.common.MethodChannel
import zendesk.android.Zendesk
import zendesk.android.ZendeskUser
import zendesk.android.events.ZendeskEvent
import zendesk.android.events.ZendeskEventListener
import zendesk.android.messaging.MessagingScreen
import zendesk.messaging.android.DefaultMessagingFactory
import zendesk.messaging.android.push.PushNotifications
import zendesk.messaging.android.push.PushResponsibility

class ZendeskMessaging(
    private val plugin: ZendeskMessagingPlugin,
    private val channel: MethodChannel
) {
    companion object {
        const val TAG = "[ZendeskMessaging]"

        // Method channel event keys
        const val EVENT_UNREAD_MESSAGES = "unread_messages"
        const val EVENT_ZENDESK_EVENT = "zendesk_event"
    }

    // Event listener for all Zendesk events
    private val zendeskEventListener = ZendeskEventListener { zendeskEvent ->
        handleZendeskEvent(zendeskEvent)
    }

    private fun handleZendeskEvent(zendeskEvent: ZendeskEvent) {
        when (zendeskEvent) {
            is ZendeskEvent.UnreadMessageCountChanged -> {
                // Legacy callback for backwards compatibility
                channel.invokeMethod(
                    EVENT_UNREAD_MESSAGES,
                    mapOf("messages_count" to zendeskEvent.currentUnreadCount)
                )
                // New event system
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "unreadMessageCountChanged",
                        "timestamp" to System.currentTimeMillis(),
                        "totalUnreadCount" to zendeskEvent.currentUnreadCount
                    )
                )
            }

            is ZendeskEvent.AuthenticationFailed -> {
                val isJwtExpired = zendeskEvent.error.message?.contains("expired", ignoreCase = true) == true
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "authenticationFailed",
                        "timestamp" to System.currentTimeMillis(),
                        "errorCode" to "authentication_failed",
                        "errorMessage" to (zendeskEvent.error.message ?: "Unknown error"),
                        "isJwtExpired" to isJwtExpired
                    )
                )
            }

            is ZendeskEvent.FieldValidationFailed -> {
                val errorMessages = zendeskEvent.errors.map { it.toString() }
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "fieldValidationFailed",
                        "timestamp" to System.currentTimeMillis(),
                        "errors" to errorMessages
                    )
                )
            }

            is ZendeskEvent.ConnectionStatusChanged -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "connectionStatusChanged",
                        "timestamp" to System.currentTimeMillis(),
                        "status" to zendeskEvent.connectionStatus.name.lowercase()
                    )
                )
            }

            is ZendeskEvent.SendMessageFailed -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "sendMessageFailed",
                        "timestamp" to System.currentTimeMillis(),
                        "errorMessage" to (zendeskEvent.cause.message ?: "Unknown error")
                    )
                )
            }

            is ZendeskEvent.ConversationAdded -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "conversationAdded",
                        "timestamp" to System.currentTimeMillis(),
                        "conversationId" to zendeskEvent.conversationId
                    )
                )
            }

            is ZendeskEvent.ConversationStarted -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "conversationStarted",
                        "timestamp" to System.currentTimeMillis(),
                        "conversationId" to zendeskEvent.conversationId
                    )
                )
            }

            is ZendeskEvent.ConversationOpened -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "conversationOpened",
                        "timestamp" to System.currentTimeMillis(),
                        "conversationId" to zendeskEvent.conversationId
                    )
                )
            }

            is ZendeskEvent.MessagesShown -> {
                val messagesData = zendeskEvent.messages.map { message ->
                    mapOf(
                        "id" to message.id,
                        "conversationId" to zendeskEvent.conversationId
                    )
                }
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "messagesShown",
                        "timestamp" to System.currentTimeMillis(),
                        "conversationId" to zendeskEvent.conversationId,
                        "messages" to messagesData
                    )
                )
            }

            is ZendeskEvent.ProactiveMessageDisplayed -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "proactiveMessageDisplayed",
                        "timestamp" to System.currentTimeMillis(),
                        "proactiveMessageId" to "",
                        "campaignId" to null
                    )
                )
            }

            is ZendeskEvent.ProactiveMessageClicked -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "proactiveMessageClicked",
                        "timestamp" to System.currentTimeMillis(),
                        "proactiveMessageId" to "",
                        "campaignId" to null
                    )
                )
            }

            is ZendeskEvent.ConversationWithAgentRequested -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "conversationWithAgentRequested",
                        "timestamp" to System.currentTimeMillis(),
                        "conversationId" to ""
                    )
                )
            }

            is ZendeskEvent.ConversationServedByAgent -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "conversationServedByAgent",
                        "timestamp" to System.currentTimeMillis(),
                        "conversationId" to ""
                    )
                )
            }

            is ZendeskEvent.MessagingOpened -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "messagingOpened",
                        "timestamp" to System.currentTimeMillis()
                    )
                )
            }

            is ZendeskEvent.MessagingClosed -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "messagingClosed",
                        "timestamp" to System.currentTimeMillis()
                    )
                )
            }

            is ZendeskEvent.NewConversationButtonClicked -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "newConversationButtonClicked",
                        "timestamp" to System.currentTimeMillis()
                    )
                )
            }

            is ZendeskEvent.PostbackButtonClicked -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "postbackButtonClicked",
                        "timestamp" to System.currentTimeMillis(),
                        "conversationId" to "",
                        "actionName" to ""
                    )
                )
            }

            is ZendeskEvent.ConversationExtensionOpened -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "conversationExtensionOpened",
                        "timestamp" to System.currentTimeMillis(),
                        "conversationId" to "",
                        "extensionUrl" to ""
                    )
                )
            }

            is ZendeskEvent.ConversationExtensionDisplayed -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "conversationExtensionDisplayed",
                        "timestamp" to System.currentTimeMillis(),
                        "conversationId" to "",
                        "extensionUrl" to ""
                    )
                )
            }

            is ZendeskEvent.ArticleBrowserClicked -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "articleBrowserClicked",
                        "timestamp" to System.currentTimeMillis(),
                        "articleUrl" to ""
                    )
                )
            }

            is ZendeskEvent.ArticleClicked -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "articleClicked",
                        "timestamp" to System.currentTimeMillis(),
                        "articleUrl" to "",
                        "conversationId" to ""
                    )
                )
            }

            is ZendeskEvent.NotificationDisplayed -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "notificationDisplayed",
                        "timestamp" to System.currentTimeMillis(),
                        "conversationId" to ""
                    )
                )
            }

            is ZendeskEvent.NotificationOpened -> {
                channel.invokeMethod(
                    EVENT_ZENDESK_EVENT,
                    mapOf(
                        "type" to "notificationOpened",
                        "timestamp" to System.currentTimeMillis(),
                        "conversationId" to ""
                    )
                )
            }

            else -> {
                // Default branch for forward compatibility with Zendesk SDK and its `ZendeskEvent` expansion
                println("$TAG - Unknown event type: $zendeskEvent")
            }
        }
    }

    fun initialize(channelKey: String, result: MethodChannel.Result) {
        println("$TAG - Channel Key - $channelKey")
        Zendesk.initialize(
            plugin.activity!!,
            channelKey,
            successCallback = { value ->
                plugin.isInitialized = true
                println("$TAG - initialize success - $value")
                result.success(null)
            },
            failureCallback = { error ->
                plugin.isInitialized = false
                println("$TAG - initialize failure - $error")
                result.error("initialize_error", error.message, null)
            },
            messagingFactory = DefaultMessagingFactory()
        )
    }

    fun invalidate() {
        Zendesk.instance.removeEventListener(zendeskEventListener)
        Zendesk.invalidate()
        plugin.isInitialized = false
        plugin.isLoggedIn = false
        println("$TAG - invalidated")
    }

    fun show() {
        Zendesk.instance.messaging.showMessaging(
            plugin.activity!!,
            MessagingScreen.MostRecentActiveConversation()
        )
        println("$TAG - show")
    }

    fun showConversation(conversationId: String) {
        Zendesk.instance.messaging.showMessaging(
            plugin.activity!!,
            MessagingScreen.Conversation(id = conversationId)
        )
        println("$TAG - showConversation: $conversationId")
    }

    fun showConversationList() {
        Zendesk.instance.messaging.showMessaging(
            plugin.activity!!,
            MessagingScreen.ConversationsList
        )
        println("$TAG - showConversationList")
    }

    fun startNewConversation() {
        Zendesk.instance.messaging.showMessaging(
            plugin.activity!!,
            MessagingScreen.NewConversation()
        )
        println("$TAG - startNewConversation")
    }

    fun getUnreadMessageCount(): Int =
        try {
            Zendesk.instance.messaging.getUnreadMessageCount()
        } catch (error: Throwable) {
            println("$TAG - getUnreadMessageCount error: ${error.message}")
            0
        }

    fun getUnreadMessageCountForConversation(conversationId: String): Int =
        try {
            Zendesk.instance.messaging.getUnreadMessageCount(conversationId)
        } catch (error: Throwable) {
            println("$TAG - getUnreadMessageCountForConversation error: ${error.message}")
            0
        }

    fun setConversationTags(tags: List<String>) {
        Zendesk.instance.messaging.setConversationTags(tags)
        println("$TAG - setConversationTags: $tags")
    }

    fun clearConversationTags() {
        Zendesk.instance.messaging.clearConversationTags()
        println("$TAG - clearConversationTags")
    }

    fun loginUser(jwt: String, result: MethodChannel.Result) {
        Zendesk.instance.loginUser(
            jwt,
            { user ->
                plugin.isLoggedIn = true
                result.success(
                    mapOf(
                        "id" to user.id,
                        "externalId" to user.externalId,
                        "authenticationType" to getAuthenticationType(user)
                    )
                )
                println("$TAG - loginUser success")
            },
            { error ->
                println("$TAG - Login failure : ${error.message}")
                result.error("login_error", error.message, null)
            }
        )
    }

    fun logoutUser(result: MethodChannel.Result) {
        Zendesk.instance.logoutUser(
            successCallback = {
                plugin.isLoggedIn = false
                result.success(null)
                println("$TAG - logoutUser success")
            },
            failureCallback = { error ->
                println("$TAG - Logout failure : ${error.message}")
                result.error("logout_error", error.message, null)
            }
        )
        Zendesk.instance.removeEventListener(zendeskEventListener)
    }

    fun getCurrentUser(result: MethodChannel.Result) {
        try {
            Zendesk.instance.getCurrentUser { user ->
                if (user != null) {
                    result.success(
                        mapOf(
                            "id" to user.id,
                            "externalId" to user.externalId,
                            "authenticationType" to getAuthenticationType(user)
                        )
                    )
                } else {
                    result.success(null)
                }
            }
        } catch (error: Throwable) {
            println("$TAG - getCurrentUser error: ${error.message}")
            result.success(null)
        }
    }

    private fun getAuthenticationType(user: ZendeskUser): String {
        return try {
            when (user.authenticationType) {
                zendesk.android.ZendeskAuthenticationType.Jwt -> "jwt"
                else -> "anonymous"
            }
        } catch (e: Throwable) {
            "anonymous"
        }
    }

    fun getConnectionStatus(): String {
        return try {
            // Connection status is obtained from events, return current known state
            "unknown"
        } catch (error: Throwable) {
            println("$TAG - getConnectionStatus error: ${error.message}")
            "unknown"
        }
    }

    fun listenMessageCountChanged() {
        // To add the event listener to your Zendesk instance:
        Zendesk.instance.addEventListener(zendeskEventListener)
        println("$TAG - listenMessageCountChanged - Event listener added")
    }

    fun setConversationFields(fields: Map<String, String>) {
        Zendesk.instance.messaging.setConversationFields(fields)
        println("$TAG - setConversationFields: $fields")
    }

    fun clearConversationFields() {
        Zendesk.instance.messaging.clearConversationFields()
        println("$TAG - clearConversationFields")
    }

    // ============================================================================
    // Push Notifications
    // ============================================================================

    /**
     * Update the push notification token with Zendesk.
     * Call this when receiving a new FCM token.
     */
    fun updatePushNotificationToken(token: String) {
        try {
            PushNotifications.updatePushNotificationToken(token)
            println("$TAG - updatePushNotificationToken: token updated")
        } catch (error: Throwable) {
            println("$TAG - updatePushNotificationToken error: ${error.message}")
            throw error
        }
    }

    /**
     * Check if a push notification should be displayed by Zendesk.
     * Returns the responsibility indicating how to handle the notification.
     */
    fun shouldBeDisplayed(messageData: Map<String, String>): String {
        return try {
            val responsibility = PushNotifications.shouldBeDisplayed(messageData)
            val result = when (responsibility) {
                PushResponsibility.MESSAGING_SHOULD_DISPLAY -> "messaging_should_display"
                PushResponsibility.MESSAGING_SHOULD_NOT_DISPLAY -> "messaging_should_not_display"
                PushResponsibility.NOT_FROM_MESSAGING -> "not_from_messaging"
                else -> "unknown"
            }
            println("$TAG - shouldBeDisplayed: $result")
            result
        } catch (error: Throwable) {
            println("$TAG - shouldBeDisplayed error: ${error.message}")
            "unknown"
        }
    }

    /**
     * Handle and display a push notification.
     * Returns true if the notification was handled by Zendesk.
     */
    fun handleNotification(context: Context, messageData: Map<String, String>): Boolean {
        return try {
            val responsibility = PushNotifications.shouldBeDisplayed(messageData)
            if (responsibility == PushResponsibility.MESSAGING_SHOULD_DISPLAY) {
                PushNotifications.displayNotification(context, messageData)
                println("$TAG - handleNotification: notification displayed")
                true
            } else {
                println("$TAG - handleNotification: not a Zendesk notification")
                false
            }
        } catch (error: Throwable) {
            println("$TAG - handleNotification error: ${error.message}")
            false
        }
    }

    /**
     * Handle a notification tap event.
     * Opens the messaging UI to the relevant conversation.
     */
    fun handleNotificationTap(context: Context, messageData: Map<String, String>) {
        try {
            val responsibility = PushNotifications.shouldBeDisplayed(messageData)
            if (responsibility == PushResponsibility.MESSAGING_SHOULD_DISPLAY) {
                // Show messaging UI - the SDK will navigate to the correct conversation
                Zendesk.instance.messaging.showMessaging(
                    plugin.activity!!,
                    MessagingScreen.MostRecentActiveConversation()
                )
                println("$TAG - handleNotificationTap: opened messaging")
            } else {
                println("$TAG - handleNotificationTap: not a Zendesk notification")
            }
        } catch (error: Throwable) {
            println("$TAG - handleNotificationTap error: ${error.message}")
            throw error
        }
    }
}
