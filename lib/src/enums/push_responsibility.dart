/// Indicates how a push notification should be handled.
///
/// This enum is returned by [ZendeskMessaging.shouldBeDisplayed] to help
/// determine the appropriate action for an incoming push notification.
enum ZendeskPushResponsibility {
  /// The notification is from Zendesk Messaging and should be displayed.
  ///
  /// Call [ZendeskMessaging.handleNotification] to let the SDK display it.
  messagingShouldDisplay,

  /// The notification is from Zendesk Messaging but should not be displayed.
  ///
  /// This typically occurs when the user is already viewing the conversation.
  messagingShouldNotDisplay,

  /// The notification is not from Zendesk Messaging.
  ///
  /// Handle this notification with your own notification logic.
  notFromMessaging,

  /// Unknown responsibility (fallback).
  unknown;

  /// Creates a [ZendeskPushResponsibility] from a string value.
  ///
  /// Returns [unknown] if the string doesn't match any known value.
  static ZendeskPushResponsibility fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'messagingshoulddisplay':
      case 'messaging_should_display':
        return messagingShouldDisplay;
      case 'messagingshouldnotdisplay':
      case 'messaging_should_not_display':
        return messagingShouldNotDisplay;
      case 'notfrommessaging':
      case 'not_from_messaging':
        return notFromMessaging;
      default:
        return unknown;
    }
  }
}
