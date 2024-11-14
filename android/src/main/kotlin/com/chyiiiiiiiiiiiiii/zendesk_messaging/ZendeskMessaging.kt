import android.content.Intent
import com.chyiiiiiiiiiiiiii.zendesk_messaging.ZendeskMessagingPlugin
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import zendesk.android.Zendesk
import zendesk.android.ZendeskUser
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
        const val INITIALIZE_SUCCESS: String = "initialize_success"
        const val INITIALIZE_FAILURE: String = "initialize_failure"
        const val LOGIN_SUCCESS: String = "login_success"
        const val LOGIN_FAILURE: String = "login_failure"
        const val LOGOUT_SUCCESS: String = "logout_success"
        const val LOGOUT_FAILURE: String = "logout_failure"
        const val UNREAD_MESSAGES: String = "unread_messages"
    }

    // To create and use the event listener:
    private val zendeskEventListener = ZendeskEventListener { zendeskEvent ->
        when (zendeskEvent) {
            is ZendeskEvent.UnreadMessageCountChanged -> {

                channel.invokeMethod(
                    UNREAD_MESSAGES,
                    mapOf("messages_count" to zendeskEvent.currentUnreadCount)
                )

            }

            else -> {
                // Default branch for forward compatibility with Zendesk SDK and its `ZendeskEvent` expansion
            }
        }
    }

    fun initialize(channelKey: String) {
        println("$TAG - Channel Key - $channelKey")
        Zendesk.initialize(
            plugin.activity!!,
            channelKey,
            successCallback = { value ->
                plugin.isInitialized = true
                println("$TAG - initialize success - $value")
                channel.invokeMethod(INITIALIZE_SUCCESS, null)
            },
            failureCallback = { error ->
                plugin.isInitialized = false
                println("$TAG - initialize failure - $error")
                channel.invokeMethod(INITIALIZE_FAILURE, mapOf("error" to error.message))
            },
            messagingFactory = DefaultMessagingFactory()
        )
    }

    fun invalidate() {
        Zendesk.instance.removeEventListener(zendeskEventListener)
        Zendesk.invalidate()
        plugin.isInitialized = false
        println("$TAG - invalidated")
    }

    fun show() {
        Zendesk.instance.messaging.showMessaging(plugin.activity!!, Intent.FLAG_ACTIVITY_NEW_TASK)
        println("$TAG - show")
    }

    fun getUnreadMessageCount(): Int =
        try {
            Zendesk.instance.messaging.getUnreadMessageCount()
        } catch (error: Throwable) {
            0
        }

    fun setConversationTags(tags: List<String>) {
        Zendesk.instance.messaging.setConversationTags(tags)
    }

    fun clearConversationTags() {
        Zendesk.instance.messaging.clearConversationTags()
    }

    fun loginUser(jwt: String) {
        Zendesk.instance.loginUser(
            jwt,
            { value: ZendeskUser? ->
                plugin.isLoggedIn = true
                value?.let {
                    channel.invokeMethod(
                        LOGIN_SUCCESS,
                        mapOf("id" to it.id, "externalId" to it.externalId)
                    )
                } ?: run {
                    channel.invokeMethod(LOGIN_SUCCESS, mapOf("id" to null, "externalId" to null))
                }
            },
            { error: Throwable? ->
                println("$TAG - Login failure : ${error?.message}")
                println(error)
                channel.invokeMethod(LOGIN_FAILURE, mapOf("error" to error?.message))
            })
    }

    fun logoutUser() {
        GlobalScope.launch(Dispatchers.Main) {
            try {
                Zendesk.instance.logoutUser(successCallback = {
                    plugin.isLoggedIn = false
                    channel.invokeMethod(LOGOUT_SUCCESS, null)
                }, failureCallback = {
                    channel.invokeMethod(LOGOUT_FAILURE, null)
                })
                Zendesk.instance.removeEventListener(zendeskEventListener)
            } catch (error: Throwable) {
                println("$TAG - Logout failure : ${error.message}")
                channel.invokeMethod(LOGOUT_FAILURE, mapOf("error" to error.message))
            }
        }
    }

    fun listenMessageCountChanged() {
        // To add the event listener to your Zendesk instance:
        Zendesk.instance.addEventListener(zendeskEventListener)
    }

    fun setConversationFields(fields: Map<String, String>) {
        Zendesk.instance.messaging.setConversationFields(fields)
    }

    fun clearConversationFields() {
        Zendesk.instance.messaging.clearConversationFields()
    }
}
