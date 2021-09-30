import UIKit
import ZendeskSDKMessaging
import ZendeskSDKLogger

public class ZendeskMessaging {
    
    let channelKey = "eyJzZXR0aW5nc191cmwiOiJodHRwczovL2hhbmFtaWhlbHAuemVuZGVzay5jb20vbW9iaWxlX3Nka19hcGkvc2V0dGluZ3MvMDFGR1BGVFQ1Q1hFRjdRWVkwUkg2R0JYS0MuanNvbiJ9"
    
    func initialize() {
        Messaging.initialize(channelKey: channelKey) { result in
                    // Tracking the error from initialization failures in your
                    // crash reporting dashboard will help to triage any unexpected failures in production
            if case let .failure(error) = result {
                print("Zendessk Messaging - did not initialize.\nError: \(error.errorDescription ?? "")")
            } else {
                print("Zendessk Messaging -  initialize - success")
            }
        }
        //
        Logger.enabled = true
        Logger.level = .default
    }

    func show(rootViewController: UIViewController?) {
        guard let messagingViewController = Messaging.instance?.messagingViewController() else { return }
        guard let rootViewController = rootViewController else { return }
        rootViewController.present(messagingViewController, animated: true, completion: nil)
    }
    
}
