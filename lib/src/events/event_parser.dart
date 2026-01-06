import '../enums/connection_status.dart';
import '../models/zendesk_message.dart';
import 'zendesk_event.dart';

/// Utility class for parsing Zendesk events from native platform data.
///
/// This class handles the deserialization of event data received from
/// the native Android and iOS SDKs.
class ZendeskEventParser {
  ZendeskEventParser._();

  /// Parse a native event map into a [ZendeskEvent].
  ///
  /// Returns `null` if the data is null, not a map, or contains an
  /// unknown event type.
  ///
  /// Example:
  /// ```dart
  /// final event = ZendeskEventParser.parse({
  ///   'type': 'unreadMessageCountChanged',
  ///   'timestamp': 1704067200000,
  ///   'totalUnreadCount': 5,
  /// });
  /// ```
  static ZendeskEvent? parse(dynamic data) {
    if (data == null) return null;
    if (data is! Map) return null;
    return _parseMap(Map<String, dynamic>.from(data));
  }

  static ZendeskEvent? _parseMap(Map<String, dynamic> map) {
    final type = map['type'] as String?;
    final timestamp = _parseTimestamp(map['timestamp']);

    return switch (type) {
      // Core events
      'unreadMessageCountChanged' => UnreadMessageCountChanged(
          timestamp: timestamp,
          totalUnreadCount: map['totalUnreadCount'] as int? ?? 0,
          conversationId: map['conversationId'] as String?,
          conversationUnreadCount: map['conversationUnreadCount'] as int?,
        ),
      'authenticationFailed' => AuthenticationFailed(
          timestamp: timestamp,
          errorCode: map['errorCode'] as String? ?? 'unknown',
          errorMessage: map['errorMessage'] as String? ?? 'Unknown error',
          isJwtExpired: map['isJwtExpired'] as bool? ?? false,
        ),
      'fieldValidationFailed' => FieldValidationFailed(
          timestamp: timestamp,
          errors: _parseStringList(map['errors']),
        ),
      'connectionStatusChanged' => ConnectionStatusChanged(
          timestamp: timestamp,
          status: ZendeskConnectionStatus.fromString(
            map['status'] as String?,
          ),
        ),
      'sendMessageFailed' => SendMessageFailed(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String?,
          errorMessage: map['errorMessage'] as String? ?? 'Unknown error',
        ),

      // Conversation events
      'conversationAdded' => ConversationAdded(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String? ?? '',
        ),
      'conversationStarted' => ConversationStarted(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String? ?? '',
        ),
      'conversationOpened' => ConversationOpened(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String?,
        ),
      'messagesShown' => MessagesShown(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String? ?? '',
          messages: _parseMessages(map['messages']),
        ),
      'conversationWithAgentRequested' => ConversationWithAgentRequested(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String? ?? '',
        ),
      'conversationWithAgentAssigned' => ConversationWithAgentAssigned(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String? ?? '',
        ),
      'conversationServedByAgent' => ConversationServedByAgent(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String? ?? '',
          agentId: map['agentId'] as String?,
        ),

      // UI events
      'messagingOpened' => MessagingOpened(timestamp: timestamp),
      'messagingClosed' => MessagingClosed(timestamp: timestamp),
      'newConversationButtonClicked' =>
        NewConversationButtonClicked(timestamp: timestamp),
      'postbackButtonClicked' => PostbackButtonClicked(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String? ?? '',
          actionName: map['actionName'] as String? ?? '',
        ),
      'proactiveMessageDisplayed' => ProactiveMessageDisplayed(
          timestamp: timestamp,
          proactiveMessageId: map['proactiveMessageId'] as String? ?? '',
          campaignId: map['campaignId'] as String?,
        ),
      'proactiveMessageClicked' => ProactiveMessageClicked(
          timestamp: timestamp,
          proactiveMessageId: map['proactiveMessageId'] as String? ?? '',
          campaignId: map['campaignId'] as String?,
        ),
      'articleClicked' => ArticleClicked(
          timestamp: timestamp,
          articleUrl: map['articleUrl'] as String? ?? '',
          conversationId: map['conversationId'] as String?,
        ),
      'articleBrowserClicked' => ArticleBrowserClicked(
          timestamp: timestamp,
          articleUrl: map['articleUrl'] as String? ?? '',
        ),
      'conversationExtensionOpened' => ConversationExtensionOpened(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String? ?? '',
          extensionUrl: map['extensionUrl'] as String? ?? '',
        ),
      'conversationExtensionDisplayed' => ConversationExtensionDisplayed(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String? ?? '',
          extensionUrl: map['extensionUrl'] as String? ?? '',
        ),

      // Notification events
      'notificationDisplayed' => NotificationDisplayed(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String? ?? '',
        ),
      'notificationOpened' => NotificationOpened(
          timestamp: timestamp,
          conversationId: map['conversationId'] as String? ?? '',
        ),

      // Unknown event type
      _ => null,
    };
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static List<ZendeskMessage> _parseMessages(dynamic value) {
    if (value is List) {
      return value
          .map((m) => ZendeskMessage.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    }
    return [];
  }
}
