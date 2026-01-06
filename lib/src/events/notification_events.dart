part of 'zendesk_event.dart';

/// Triggered when a push notification is displayed.
///
/// This event is Android-only.
final class NotificationDisplayed extends ZendeskEvent {
  /// Creates a new [NotificationDisplayed] event.
  const NotificationDisplayed({
    required super.timestamp,
    required this.conversationId,
  });

  /// The ID of the conversation associated with the notification.
  final String conversationId;
}

/// Triggered when a push notification is opened by the user.
///
/// This event is Android-only.
final class NotificationOpened extends ZendeskEvent {
  /// Creates a new [NotificationOpened] event.
  const NotificationOpened({
    required super.timestamp,
    required this.conversationId,
  });

  /// The ID of the conversation associated with the notification.
  final String conversationId;
}
