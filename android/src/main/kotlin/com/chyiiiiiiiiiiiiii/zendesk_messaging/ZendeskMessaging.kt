import android.content.Intent
import android.util.Log
import com.chyiiiiiiiiiiiiii.zendesk_messaging.ZendeskMessagingPlugin
import io.flutter.plugin.common.MethodChannel
import zendesk.messaging.android.FailureCallback
import zendesk.messaging.android.Messaging
import zendesk.messaging.android.MessagingError
import zendesk.messaging.android.SuccessCallback

class ZendeskMessaging(private val plugin: ZendeskMessagingPlugin, private val channel: MethodChannel) {

    private val tag = "[ZendeskMessaging]"

    fun initialize(channelKey: String) {
        println("$tag - Channel Key - $channelKey")
        Messaging.initialize(
            plugin.activity!!,
            channelKey, successCallback = object : SuccessCallback<Messaging>{
                override fun onSuccess(value: Messaging) {
                    plugin.isInitialize = true;
                    println("$tag - initialize success - $value")
                }
            }, failureCallback = object: FailureCallback<MessagingError>{
                override fun onFailure(error: MessagingError?) {
                    plugin.isInitialize = false;
                    println("$tag - initialize failure - $error")
                }
                })
    }

    fun show() {
        Messaging.instance().showMessaging(plugin.activity!!, Intent.FLAG_ACTIVITY_NEW_TASK)
        println("$tag - show")
    }

}
