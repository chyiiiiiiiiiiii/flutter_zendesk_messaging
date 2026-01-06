/// Zendesk Events library.
///
/// This library contains all Zendesk SDK events using a sealed class hierarchy
/// to enable exhaustive pattern matching.
library;

import '../enums/connection_status.dart';
import '../models/zendesk_message.dart';

part 'core_events.dart';
part 'conversation_events.dart';
part 'ui_events.dart';
part 'notification_events.dart';

/// Base class for all Zendesk events.
///
/// All Zendesk SDK events extend this sealed class, enabling exhaustive
/// pattern matching in Dart 3.x.
///
/// Example:
/// ```dart
/// ZendeskMessaging.eventStream.listen((event) {
///   switch (event) {
///     case UnreadMessageCountChanged(:final totalUnreadCount):
///       print('Unread: $totalUnreadCount');
///     case AuthenticationFailed(:final isJwtExpired):
///       if (isJwtExpired) refreshToken();
///     case ConnectionStatusChanged(:final status):
///       print('Status: ${status.name}');
///     default:
///       break;
///   }
/// });
/// ```
sealed class ZendeskEvent {
  /// Creates a new [ZendeskEvent] with the given timestamp.
  const ZendeskEvent({required this.timestamp});

  /// The timestamp when the event occurred.
  final DateTime timestamp;
}
