import android.content.Intent
import android.util.Log
import com.chyiiiiiiiiiiiiii.zendesk_messaging.ZendeskMessagingPlugin
import io.flutter.plugin.common.MethodChannel
import zendesk.messaging.android.FailureCallback
import zendesk.messaging.android.Messaging
import zendesk.messaging.android.MessagingError
import zendesk.messaging.android.SuccessCallback

class ZendeskMessaging(private val plugin: ZendeskMessagingPlugin, private val channel: MethodChannel) {

    private val MESSAGING_CHANNEL_KEY =
        "eyJzZXR0aW5nc191cmwiOiJodHRwczovL2hhbmFtaWhlbHAuemVuZGVzay5jb20vbW9iaWxlX3Nka19hcGkvc2V0dGluZ3MvMDFGR0tDRTlSNEFLWDBGOUc2Sk04Mk5RQU0uanNvbiJ9" // F/ Firebase console -> Project settings -> Cloud messaging -> Sender ID


    fun initialize() {
        Messaging.initialize(
            plugin.activity!!,
            MESSAGING_CHANNEL_KEY,successCallback = object : SuccessCallback<Messaging>{
                override fun onSuccess(value: Messaging) {

                }
            }, failureCallback = object: FailureCallback<MessagingError>{
                override fun onFailure(cause: MessagingError?) {
                }
            })
    }

    fun show() {
        Messaging.instance().showMessaging(plugin.activity!!, Intent.FLAG_ACTIVITY_NEW_TASK)
    }

}
