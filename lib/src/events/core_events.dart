part of 'zendesk_event.dart';

/// Triggered when the unread message count changes.
///
/// This event provides both the total unread count and optionally
/// conversation-specific details.
final class UnreadMessageCountChanged extends ZendeskEvent {
  /// Creates a new [UnreadMessageCountChanged] event.
  const UnreadMessageCountChanged({
    required super.timestamp,
    required this.totalUnreadCount,
    this.conversationId,
    this.conversationUnreadCount,
  });

  /// The total unread message count across all conversations.
  final int totalUnreadCount;

  /// The ID of the conversation that triggered the change (if available).
  final String? conversationId;

  /// The unread count for the specific conversation (if available).
  final int? conversationUnreadCount;
}

/// Triggered when authentication fails.
///
/// This event provides detailed error information including whether
/// the JWT token has expired.
final class AuthenticationFailed extends ZendeskEvent {
  /// Creates a new [AuthenticationFailed] event.
  const AuthenticationFailed({
    required super.timestamp,
    required this.errorCode,
    required this.errorMessage,
    required this.isJwtExpired,
  });

  /// The error code from the SDK.
  final String errorCode;

  /// A human-readable error message.
  final String errorMessage;

  /// Whether the failure was due to an expired JWT token.
  ///
  /// If true, the application should refresh the JWT and retry login.
  final bool isJwtExpired;
}

/// Triggered when field validation fails.
///
/// This event occurs when conversation fields set via
/// [ZendeskMessaging.setConversationFields] are invalid.
final class FieldValidationFailed extends ZendeskEvent {
  /// Creates a new [FieldValidationFailed] event.
  const FieldValidationFailed({
    required super.timestamp,
    required this.errors,
  });

  /// List of validation error messages.
  final List<String> errors;
}

/// Triggered when the SDK connection status changes.
///
/// Monitor this event to track the SDK's network connectivity state.
final class ConnectionStatusChanged extends ZendeskEvent {
  /// Creates a new [ConnectionStatusChanged] event.
  const ConnectionStatusChanged({
    required super.timestamp,
    required this.status,
  });

  /// The new connection status.
  final ZendeskConnectionStatus status;
}

/// Triggered when sending a message fails.
///
/// This event provides error details when a message cannot be sent.
final class SendMessageFailed extends ZendeskEvent {
  /// Creates a new [SendMessageFailed] event.
  const SendMessageFailed({
    required super.timestamp,
    this.conversationId,
    required this.errorMessage,
  });

  /// The ID of the conversation where the send failed.
  final String? conversationId;

  /// A description of the error.
  final String errorMessage;
}
